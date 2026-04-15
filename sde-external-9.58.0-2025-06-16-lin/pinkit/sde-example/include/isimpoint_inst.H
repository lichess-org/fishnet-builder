//
// Copyright (C) 2013-2024 Intel Corporation.
// SPDX-License-Identifier: MIT
//

#ifndef ISIMPOINT_INST_H
#define ISIMPOINT_INST_H

#include <map>
#include <unordered_set>
#include <queue>
#include <iostream>
#include <fstream>
#include <memory>
#include <string.h>
#include <math.h>
#include <unistd.h>

#include "pin.H"

#include "emu.H"
#include "pinplay.H"
#include "sde-pinplay-supp.H"

#include "isimpoint_profiles.H"

#define ISIMPOINT_MAX_IMAGES 64

/*
    When to emit frequency (bbv/ldv) vectors?
    Two knobs control this:
    1. -emit_vectors
        Default 1.
        If set to 0, some external tool (such as looppoint) will trigger
         vector emission.
    2. -delay_vector_emission
        Added to ease marker management in PC+Count regions. 
          (Iregions behavior un-affected.)
        Default 1 :
            Emission happen at the beginning of the next basic block
            following the end of slice is detected.
        If set to 0, we have the old way of outputting vectors as soon
         as slice end is detected.
*/
class IMG_INFO
{
  public:
    IMG_INFO(IMG img);
    ~IMG_INFO();
    INT32 Id() { return _imgId; }
    const CHAR* Name() { return _name.c_str(); }
    ADDRINT LowAddress() { return _low_address; }

  private:
    std::string _name;
    ADDRINT _low_address;
    INT32 _imgId;
};

class IMG_MANAGER
{
  private:
    std::map<INT32, IMG_INFO*> _img_info;
    PIN_LOCK _imagesLock;

  public:
    IMG_MANAGER() { PIN_InitLock(&_imagesLock); }

    VOID AddImage(IMG img)
    {
        PIN_GetLock(&_imagesLock, 1);
        _img_info[IMG_Id(img)] = new IMG_INFO(img);
        PIN_ReleaseLock(&_imagesLock);
    }
    IMG_INFO* GetImageInfo(INT32 id)
    {
        IMG_INFO* imageInfo = NULL;
        PIN_GetLock(&_imagesLock, 1);
        if (_img_info.find(id) != _img_info.end())
            imageInfo = _img_info[id];
        PIN_ReleaseLock(&_imagesLock);
        return imageInfo;
    }
};

class ISIMPOINT
{
  public:
    std::string commandLine;
    IMG_MANAGER img_manager;

    // Flags to let an external friendly class know that frequency vector
    // needs to be emitted
    BOOL* _vectorPending = nullptr;

    static KNOB_COMMENT knob_family;
    static KNOB<BOOL> KnobBbv;
    static KNOB<BOOL> KnobLdv;
    static KNOB<std::string> KnobOutputFile;
    static KNOB<INT64> KnobSliceSize;
    static KNOB<BOOL> KnobNoSymbolic;
    static KNOB<BOOL> KnobEmitVectors;
    static KNOB<BOOL> KnobDelayVectorEmission;
    static KNOB<BOOL> KnobEmitFirstSlice;
    static KNOB<BOOL> KnobEmitLastSlice;
    static KNOB<BOOL> KnobEmitPrevBlockCounts;
    static KNOB<BOOL> KnobPid;
    static KNOB<std::string> KnobLengthFile;
    static KNOB<UINT32> KnobNumThreads;
    static KNOB<BOOL> KnobEmitPinPointsLegacy;
    UINT32 Pid = 0;

    PROFILING profiling;

  public:
    INT32 Usage()
    {
        std::cerr << "This tool collects frequency vectors  for SimPoint.\n"
                     "\n";
        std::cerr << KNOB_BASE::StringKnobSummary() << std::endl;
        return -1;
    }

    std::string CommandLine() { return commandLine; }

    IMG_MANAGER* ImageManager() { return &img_manager; }

    BOOL VectorPending(THREADID tid) { return _vectorPending[tid]; }

    BOOL InterestingThreadLut(int tid) const { return interesting_thread_lut_[tid]; }

    VOID EmitSliceEnd(ADDRINT endMarker, UINT32 imgId, THREADID tid,
                      UINT64 markerCountOffset = 0)
    {
        profiling.EmitSliceEnd(tid, endMarker, imgId, markerCountOffset, this);
    }

    static ADDRINT GetFirstIP_If(THREADID tid, ISIMPOINT* isimpoint)
    {
        return !isimpoint->profiling.slice[tid].first_eip;
    }

    static VOID GetFirstIP_Then(VOID* ip, THREADID tid, ISIMPOINT* isimpoint, UINT32 imgID)
    {
        if (!isimpoint->InterestingThreadLut(tid))
            return;

        auto& slice = isimpoint->profiling.slice[tid];

        slice.first_eip       = reinterpret_cast<ADDRINT>(ip);
        slice.first_eip_imgID = imgID;

        PIN_RemoveInstrumentation();
    }

    static VOID CountRepIterations(THREADID tid, ISIMPOINT* isimpoint, ADDRINT firstRepIter,
                                   BOOL executing)
    {
        if (!isimpoint->InterestingThreadLut(tid) || !executing)
            return;

        auto& slice = isimpoint->profiling.slice[tid];
        slice.CummulativeRepIterations += (1 - firstRepIter);
    }

    // this analysis routine handles block/instructions counting in the slice and decides
    // whether to end the slice. it is called for every REP instruction
    static ADDRINT CountInsInRepBbl_If(BLOCK* block, THREADID tid, ISIMPOINT* isimpoint,
                                       BOOL executing)
    {
        if (!executing)
            return false;

        auto& slice = isimpoint->profiling.slice[tid];
        block->Execute(tid);

        --slice.SliceTimer;
        slice.last_block = block;

        return (((slice.SliceTimer) < (INT64)0) && !executing);
    }

    // this analysis routine handles block/instructions counting in the slice.
    // it is called for every non-REP instruction inside a BBL containing REP(s)
    static VOID CountInsInRepBbl(BLOCK* block, THREADID tid, ISIMPOINT* isimpoint)
    {
        auto& slice = isimpoint->profiling.slice[tid];
        block->Execute(tid);

        --slice.SliceTimer;
        slice.last_block = block;
    }

    static ADDRINT CountBlock_If(BLOCK* block, THREADID tid, ISIMPOINT* isimpoint)
    {
        auto& slice = isimpoint->profiling.slice[tid];
        block->Execute(tid);

        slice.SliceTimer -= block->StaticInstructionCount();
        slice.last_block = block;

        return ((slice.SliceTimer) < (INT64)0);
    }

    static ADDRINT CountBlockAndTrackPrevious_If(BLOCK* block, THREADID tid,
                                                 ISIMPOINT* isimpoint)
    {
        auto& slice = isimpoint->profiling.slice[tid];
        block->Execute(tid, slice.last_block, isimpoint);

        slice.SliceTimer -= block->StaticInstructionCount();
        slice.last_block = block;

        return ((slice.SliceTimer) < (INT64)0);
    }

    static VOID ResetSliceTimer(THREADID tid, ISIMPOINT* isimpoint)
    {
        if (!isimpoint->InterestingThreadLut(tid))
            return;

        auto& slice = isimpoint->profiling.slice[tid];

        slice.CumulativeInstructionCount += (slice.CurrentSliceSize - slice.SliceTimer);
        if (slice.length_queue.size())
        {
            slice.SliceTimer = (INT64)slice.length_queue.front();
            slice.length_queue.pop();
        }
        else
        {
            slice.SliceTimer = ISIMPOINT::KnobSliceSize;
        }
        slice.CurrentSliceSize = slice.SliceTimer;
    }

    static ADDRINT CheckDelayedVectorEmission(THREADID tid, ISIMPOINT* isimpoint)
    {
        return (isimpoint->VectorPending(tid));
    }

    VOID EmitVectorForFriend(ADDRINT marker, UINT32 imageid, THREADID tid,
                             ISIMPOINT* isimpoint, UINT64 markerCountOffset = 0)
    {
        if (!isimpoint->InterestingThreadLut(tid))
            return;

        ASSERTX(isimpoint->_vectorPending[tid]);
        isimpoint->_vectorPending[tid] = FALSE;
        isimpoint->ResetSliceTimer(tid, isimpoint);
        isimpoint->EmitSliceEnd(marker, imageid, tid, markerCountOffset);
    }

    static VOID DelayedVectorEmission(BLOCK* block, THREADID tid, ISIMPOINT* isimpoint)
    {
        if (!isimpoint->InterestingThreadLut(tid))
            return;

        // A slice ended but frequency vector
        // was not emitted. Do it now.
        isimpoint->EmitVectorForFriend(block->Key().Start(), block->ImgId(), tid, isimpoint,
                                       /*markerOffset*/ 1);
        // This block is not yet executed and we are using its first
        // insAddr as a marker hence we provide an offset of 1.
    }

    static VOID CountBlock_Then(BLOCK* block, THREADID tid, ISIMPOINT* isimpoint)
    {
        if (!isimpoint->InterestingThreadLut(tid))
            return;
        if (!ISIMPOINT::KnobEmitVectors)
        {
            // do not output frequency vector but set a flag indicating
            // vector output is pending. The vector output will be
            // triggered by another class.
            isimpoint->_vectorPending[tid] = TRUE;
        }
        else if (ISIMPOINT::KnobDelayVectorEmission)
        {
            // do not output frequency vector but set a flag indicating
            // vector output is pending. The vector output will be
            // done at the beginning of the next basic block.
            isimpoint->_vectorPending[tid] = TRUE;
        }
        else
        {
            isimpoint->ResetSliceTimer(tid, isimpoint);
            isimpoint->EmitSliceEnd(block->Key().End(), block->ImgId(), tid);
        }
    }

    static VOID Trace(TRACE trace, VOID* v)
    {
        ISIMPOINT* isimpoint = reinterpret_cast<ISIMPOINT*>(v);

        for (BBL bbl = TRACE_BblHead(trace); BBL_Valid(bbl); bbl = BBL_Next(bbl))
        {
            // find the block in the map or add it if new.
            BLOCK* block =
                isimpoint->profiling.LookupBlock(bbl, ISIMPOINT::KnobEmitPrevBlockCounts);

            // Insert instrumentation to handle counting of rep instructions
            bool bbl_has_rep = false;
            for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins))
            {
                if (INS_HasRealRep(ins))
                {
                    bbl_has_rep = true;
                    INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)CountRepIterations,
                                   IARG_CALL_ORDER, CALL_ORDER_FIRST, // before CountBlock*()
                                   IARG_THREAD_ID, IARG_PTR, isimpoint,
                                   IARG_FIRST_REP_ITERATION, IARG_EXECUTING, IARG_END);
                }
            }

            // insert instrumentation to get the first IP. Every thread
            // will call PIN_RemoveInstrumentation upon creation. This
            // ensures that the thread will insert instrumentation to log
            // the first eip. Once the first eip is logged,
            // PIN_RemoveInstrumentation is called again to remove the
            // instrumentation again.
            if (ISIMPOINT::KnobEmitFirstSlice &&
                isimpoint->profiling.DoInsertGetFirstIpInstrumentation())
            {
                INS_InsertIfCall(BBL_InsHead(bbl), IPOINT_BEFORE, (AFUNPTR)GetFirstIP_If,
                                 IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_END);
                INS_InsertThenCall(BBL_InsHead(bbl), IPOINT_BEFORE, (AFUNPTR)GetFirstIP_Then,
                                   IARG_INST_PTR, IARG_THREAD_ID, IARG_PTR, isimpoint,
                                   IARG_UINT32, block->ImgId(), IARG_END);
            }

            // insert instrumentation to perform the slicing
            bool bbl_can_end_slice = true;
            if (bbl_has_rep)
            {
                // we have a REP in this BBL. due to how Pin works, we assume this is either
                // (1) a BBL of multiple instructions, ending with the first REP iteration,
                // as it is traslated by Pin, or (2) a single-instruction BBL, performing the
                // following rep iterations. in both cases we don't want this BBL to end a
                // slice -- unless it is the last rep iteration.
                // to implement this logic, we instrument in this case each instruction, and
                // not on the BBL level, as we do below for BBLs not containing REP(s)
                for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins))
                {
                    if (INS_HasRealRep(ins))
                    {
                        INS_InsertIfCall(BBL_InsTail(bbl), IPOINT_BEFORE,
                                         (AFUNPTR)CountInsInRepBbl_If, IARG_PTR, block,
                                         IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_EXECUTING,
                                         IARG_END);
                    }
                    else
                    {
                        INS_InsertCall(BBL_InsTail(bbl), IPOINT_BEFORE,
                                       (AFUNPTR)CountInsInRepBbl, IARG_PTR, block,
                                       IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_END);
                        bbl_can_end_slice = false;
                    }
                }
            }
            else
            {
                if (ISIMPOINT::KnobEmitPrevBlockCounts)
                {
                    INS_InsertIfCall(BBL_InsTail(bbl), IPOINT_BEFORE,
                                     (AFUNPTR)CountBlockAndTrackPrevious_If, IARG_PTR, block,
                                     IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_END);
                }
                else
                {
                    INS_InsertIfCall(BBL_InsTail(bbl), IPOINT_BEFORE, (AFUNPTR)CountBlock_If,
                                     IARG_PTR, block, IARG_THREAD_ID, IARG_PTR, isimpoint,
                                     IARG_END);
                }
            }

            // false only for non-REP instruction inside BBL containing REP(s)
            // true for REP instructions inside such BBL, or for entire BBLs not
            // containing REP(s)
            if (bbl_can_end_slice)
            {
                INS_InsertThenCall(BBL_InsTail(bbl), IPOINT_BEFORE, (AFUNPTR)CountBlock_Then,
                                   IARG_PTR, block, IARG_THREAD_ID, IARG_PTR, isimpoint,
                                   IARG_END);
            }

            // insert instrumentation for delayed vector emission
            if (ISIMPOINT::KnobEmitVectors && ISIMPOINT::KnobDelayVectorEmission)
            {
                INS_InsertIfCall(BBL_InsHead(bbl), IPOINT_BEFORE,
                                 (AFUNPTR)CheckDelayedVectorEmission, IARG_CALL_ORDER,
                                 CALL_ORDER_FIRST, // before CountBlock*()
                                 IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_END);
                INS_InsertThenCall(
                    BBL_InsHead(bbl), IPOINT_BEFORE, (AFUNPTR)DelayedVectorEmission,
                    IARG_CALL_ORDER, CALL_ORDER_FIRST, // before CountBlock*()
                    IARG_PTR, block, IARG_THREAD_ID, IARG_PTR, isimpoint, IARG_END);
            }

            if (isimpoint->profiling.counting_memory())
            {
                for (INS ins = BBL_InsHead(bbl);; ins = INS_Next(ins))
                {
                    // We do not count AGEN instructions here in order to avoid instrumenting
                    // Emulated instruction in PIN.
                    // TBD - Support AGEN memory operands if needed
                    BOOL agen = EMU_ISA::IsAgen(ins);
                    if ((INS_IsMemoryRead(ins) || INS_IsMemoryWrite(ins)) && !agen)
                    {
                        for (UINT32 i = 0; i < INS_MemoryOperandCount(ins); i++)
                            INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)PROFILING::CountMemory,
                                           IARG_MEMORYOP_EA, i, IARG_THREAD_ID, IARG_PTR,
                                           isimpoint, IARG_END);
                    }

                    if (ins == BBL_InsTail(bbl))
                        break;
                }
            }
        }
    }

    static VOID Image(IMG img, VOID* v)
    {
        ISIMPOINT* isimpoint = reinterpret_cast<ISIMPOINT*>(v);

        isimpoint->img_manager.AddImage(img);
        isimpoint->profiling.ImageLoaded(img);
    }

    static VOID ThreadStart(THREADID tid, CONTEXT* ctxt, INT32 flags, VOID* v)
    {
        ISIMPOINT* isimpoint = reinterpret_cast<ISIMPOINT*>(v);

        // stores this mapping to avoid further lookup
        isimpoint->interesting_thread_lut_[tid] =
            isimpoint->pinplay_engine_->IsInterestingThread(tid);

        // same as accessing isimpoint InterestingThreadLut()
        if (!isimpoint->interesting_thread_lut_[tid])
            return;

        ASSERT(tid < isimpoint->profiling._nthreads,
               "Use knob -bbthreads to increase number of threads");
        isimpoint->profiling.ThreadStart(tid, isimpoint->Pid,
                                         ISIMPOINT::KnobOutputFile.Value());
        PIN_RemoveInstrumentation();
    }

    static VOID ThreadFini(UINT32 tid, const CONTEXT* ctxt, INT32 code, VOID* v)
    {
        ISIMPOINT* isimpoint = reinterpret_cast<ISIMPOINT*>(v);
        if (!isimpoint->InterestingThreadLut(tid))
            return;

        isimpoint->profiling.ThreadFini(tid, isimpoint);
    }

    VOID GetCommand(int argc, char* argv[])
    {
        for (INT32 i = 0; i < argc; i++)
        {
            commandLine += " ";
            commandLine += argv[i];
        }
    }

    virtual VOID activate(int argc, char** argv)
    {
        // at least one type of isimpoint profilng must be enabled
        if (!KnobBbv && !KnobLdv)
            return;

        ASSERT(!KnobEmitPinPointsLegacy || KnobBbv,
               "Cannot emit legacy pinpoints (-emit_pinpoints) without -bbprofile.");

        profiling.initialize();

        GetCommand(argc, argv);

        if (KnobPid)
            Pid = getpid();

        _vectorPending = new BOOL[profiling._nthreads];
        for (UINT32 i = 0; i < profiling._nthreads; i++)
            _vectorPending[i] = FALSE;

        AddInstrumentation();

        // Get pinplay engine
        pinplay_engine_ = sde_tracing_get_pinplay_engine();
    }

    VOID AddInstrumentation()
    {
        PIN_AddThreadStartFunction(ThreadStart, this);
        PIN_AddThreadFiniFunction(ThreadFini, this);
        TRACE_AddInstrumentFunction(Trace, this);
        IMG_AddInstrumentFunction(Image, this);
    }

  private:
    PINPLAY_ENGINE* pinplay_engine_               = NULL;
    BOOL interesting_thread_lut_[SDE_MAX_THREADS] = {};
};

#endif

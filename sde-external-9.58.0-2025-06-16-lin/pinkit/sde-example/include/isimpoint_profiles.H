//
// Copyright (C) 2024-2024 Intel Corporation.
// SPDX-License-Identifier: MIT
//

#ifndef ISIMPOINT_PROFILES_H
#define ISIMPOINT_PROFILES_H

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

#define ADDRESS64_MASK (~0x3f) /* for ldv profiling, we mask-out lower 6 bits of address */

class BLOCK_KEY
{
    friend BOOL operator<(const BLOCK_KEY& p1, const BLOCK_KEY& p2);

  public:
    BLOCK_KEY(ADDRINT s, ADDRINT e, USIZE z) : _start(s), _end(e), _size(z)
    {
        ASSERTX(_end >= _start);
    };
    ADDRINT Start() const { return _start; }
    ADDRINT End() const { return _end; }
    USIZE Size() const { return _size; }
    BOOL Contains(ADDRINT addr) const;

  private:
    const ADDRINT _start;
    const ADDRINT _end;
    const USIZE _size;
};

class ISIMPOINT;

typedef std::map<INT32, INT64> BLOCK_COUNT_MAP;

class RD;
class LDV
{
  private:
    RD* _rd = nullptr;
    std::vector<UINT64> _counts;

  public:
    LDV();
    ~LDV();

    LDV(const LDV&) = delete;
    LDV(LDV&&)      = delete;

    VOID emit(std::ofstream& LdvFile);
    VOID access(ADDRINT address);
};

class BLOCK
{
  public:
    BLOCK(const BLOCK_KEY& key, INT64 instructionCount, INT32 id, INT32 imgId, UINT32 nthreads,
          BOOL emitPrevBlockCount);
    ~BLOCK();
    INT64 StaticInstructionCount() const { return _staticInstructionCount; }
    VOID Execute(THREADID tid) { _sliceBlockCount[tid]++; }
    VOID Execute(THREADID tid, const BLOCK* prev_block, ISIMPOINT* isimpoint);
    VOID EmitSliceEnd(THREADID tid, std::ofstream& bbflie);
    VOID EmitProgramEnd(const BLOCK_KEY& key, THREADID tid, std::ofstream& bbflie,
                        const ISIMPOINT* isimpoint) const;
    INT64 CumulativeBlockCount(THREADID tid) const
    {
        return _cumulativeBlockCount[tid] + _sliceBlockCount[tid];
    }
    UINT32 ImgId() const { return _imgId; }
    const BLOCK_KEY& Key() const { return _key; }
    INT32 Id() const { return _id; }

  private:
    INT64 SliceInstructionCount(THREADID tid) const
    {
        return _sliceBlockCount[tid] * _staticInstructionCount;
    }

    const INT64 _staticInstructionCount; // number of instrs in this block.
    INT32 _id;
    UINT32 _imgId;
    const BLOCK_KEY _key;

    INT64* _sliceBlockCount;
    // times this block was executed in the current slice.
    INT64* _cumulativeBlockCount;
    // times this block was executed prior to the current slice.
    BLOCK_COUNT_MAP* _blockCountMap;
    // counter for each previous block.
};

typedef std::map<BLOCK_KEY, BLOCK*> BLOCK_MAP;

typedef std::queue<UINT64> REGION_LENGTHS_QUEUE;

class SLICE_INFO
{
  public:
    static const UINT32 BUFSIZE = 100;

    INT64 CumulativeInstructionCount = 0;
    INT64 CummulativeRepIterations   = 0;

    ADDRINT first_eip      = 0; // The first time, we want a marker, but no T vector
    UINT32 first_eip_imgID = 0;
    BOOL first             = true;
    BOOL last              = false;

    // Emit the first marker immediately
    INT64 SliceTimer       = 0;
    INT64 CurrentSliceSize = 0;
    BLOCK* last_block   = NULL;
    REGION_LENGTHS_QUEUE length_queue;

    VOID ReadLengthFile(THREADID tid, std::string length_file)
    {
        std::ifstream lfile(length_file.c_str());
        ASSERT(lfile.is_open(), "Could not open length file:" + length_file);
        UINT32 lineNum   = 0;
        UINT32 recordNum = 0;
        while (true)
        {
            if (lfile.eof())
            {
                break;
            }

            CHAR record[BUFSIZE + 1];
            std::string field;

            lfile.getline(record, BUFSIZE);
            lineNum++;

            if (strnlen_s(record, BUFSIZE) == 0)
                continue;

            // first letter '#' : this is a comment
            if (record[0] == '#')
                continue;

            std::istringstream s(record);

            field.clear();
            getline(s, field);
            ASSERT(!field.empty(), "Empty length field.");
            if (recordNum == 0)
            {
                CurrentSliceSize = SliceTimer = (INT64)Uint64FromString(field);
                // cerr << "First SliceTimer " << SliceTimer << endl;
            }
            else
            {
                length_queue.push(Uint64FromString(field));
            }
            recordNum++;
        }
        lfile.close();
    }
};

class PROFILING;
class BBV_PROF
{
  public:
    std::ofstream BbFile;

    VOID StartProfile(const std::string& out_fname, PROFILING* profiling);
    VOID ImageLoad(IMG img);
    VOID EmitSliceEnd(THREADID tid, ADDRINT endMarker, UINT32 imgId, UINT64& markerCount,
                      PROFILING* profiling);
};

class LDV_PROF
{
  public:
    std::ofstream LdvFile;
    std::unique_ptr<LDV> _ldvState;

    VOID StartProfile(const std::string& out_fname, PROFILING* profiling);
    VOID ExecuteMemory(ADDRINT address) { _ldvState->access(address & ADDRESS64_MASK); }
    VOID EmitSliceEnd(THREADID tid, ADDRINT endMarker, UINT32 imgId, UINT64& markerCount,
                      PROFILING* profiling);
};

static std::string GetFilename(THREADID tid, UINT32 pid, std::string out_fname)
{
    char num[100];
    if (pid)
    {
        sprintf_s(num, sizeof(num), ".T.%u.%d", (unsigned int)pid, (int)tid);
    }
    else
    {
        sprintf_s(num, sizeof(num), ".T.%d", (int)tid);
    }
    std::string tname = num;
    return out_fname + tname;
}

class PROFILING
{
  public:
    UINT32 _nthreads = 0;

    // The start addresses of the slices
    // Needed for writing the block of the last slice
    std::unordered_set<ADDRINT> slices_start_set;
    PIN_LOCK slicesLock;

    // If KnobEmitPrevBlockCounts is enabled, this array is used
    // to assign an ID to each block as it is executed.
    // Otherwise, the ids are assigned at instrumentation time and only
    // the first entry in the vector is used,
    // since we don't know the thread id at instrumentation. Assigning
    // at instrumentation time is more efficient
    // if one does not care for the ID assignment order.
    std::vector<THREADID> _currentId;

    /* following members are per-thread arrays: */
    std::vector<BOOL> active;
    std::vector<SLICE_INFO> slice;
    std::unique_ptr<std::vector<BBV_PROF>> bbv;
    std::unique_ptr<std::vector<LDV_PROF>> ldv;
    /* add any additional profiles here */

    /* this member is needed for BBV only. further decoupling of profiles should be
     * made by encapsulating each profile's per-thread data alongside its global data.
     * in such design, this block map will be kept as part of the BBV profile global struct */
    BLOCK_MAP bbv_blocks;

    BOOL counting_memory() { return ldv.get() != nullptr; }

    VOID initialize();

    template<typename T>
    VOID StartProfile(T* profile, THREADID tid, UINT32 pid, std::string out_fname)
    {
        if (!profile) // profile not selected for this run
            return;

        (*profile)[tid].StartProfile(GetFilename(tid, pid, out_fname), this);
    }

    VOID ImageLoaded(IMG img);

    VOID ThreadStart(THREADID tid, UINT32 pid, std::string out_fname)
    {
        StartProfile(bbv.get(), tid, pid, out_fname);
        StartProfile(ldv.get(), tid, pid, out_fname);
        /* add for any additional profiles here */

        active[tid] = true;
    }

    VOID ThreadFini(THREADID tid, ISIMPOINT* sp);

    VOID EmitProgramEnd(THREADID tid, ISIMPOINT* sp);

    VOID EmitSliceStartInfo(ADDRINT endMarker, INT64 markerCount, UINT32 imgId, THREADID tid,
                            ISIMPOINT* sp);

    template<typename T>
    VOID EmitSliceEndProfile(T* profile, THREADID tid, ADDRINT endMarker, UINT32 imgId,
                             UINT64& markerCount)
    {
        if (!profile) // profile not selected for this run
            return;

        (*profile)[tid].EmitSliceEnd(tid, endMarker, imgId, markerCount, this);
    }

    VOID EmitSliceEnd(THREADID tid, ADDRINT endMarker, UINT32 imgId, UINT64 markerCount,
                      ISIMPOINT* sp);

    // Lookup a block by its id.
    // Return BlockMapPtr.end() if not found.
    BLOCK_MAP::const_iterator LookupBlock(INT32 id)
    {
        BLOCK_MAP::const_iterator bi = bbv_blocks.begin();
        for (; bi != bbv_blocks.end(); bi++)
        {
            if (bi->second->Id() == id)
                return bi;
        }
        return bi;
    }

    // Lookup a block by its BBL key.
    // Create a new one and return it if it doesn't already exist.
    BLOCK* LookupBlock(BBL bbl, BOOL emit_prev_block_counts)
    {
        BLOCK_KEY key(INS_Address(BBL_InsHead(bbl)), INS_Address(BBL_InsTail(bbl)),
                      BBL_Size(bbl));
        BLOCK_MAP::const_iterator bi = bbv_blocks.find(key);

        if (bi == bbv_blocks.end())
        {
            // Block not there, add it
            RTN rtn = INS_Rtn(BBL_InsHead(bbl));
            SEC sec = SEC_Invalid();
            IMG img = IMG_Invalid();
            if (RTN_Valid(rtn))
                sec = RTN_Sec(rtn);
            if (SEC_Valid(sec))
                img = SEC_Img(sec);

            INT32 id = 0;
            if (!emit_prev_block_counts)
            {
                id = _currentId[0]++;
            }
            BLOCK* block = new BLOCK(key, BBL_NumIns(bbl), id, IMG_Id(img), _nthreads,
                                     emit_prev_block_counts);

            bbv_blocks.emplace(key, block);

            return block;
        }
        else
        {
            return bi->second;
        }
    }

    static VOID CountMemory(ADDRINT address, THREADID tid, ISIMPOINT* isimpoint);

    VOID ExecuteMemory(THREADID tid, ADDRINT address)
    {
        ASSERT(ldv, "LDV not selected for analysis");

        (*ldv)[tid].ExecuteMemory(address & ADDRESS64_MASK);
    }

    BOOL DoInsertGetFirstIpInstrumentation()
    {
        UINT32 i;
        BOOL do_instrument = false;

        for (i = 0; i < _nthreads; i++)
        {
            if (active[i])
            {
                do_instrument |= !slice[i].first_eip;
            }
        }
        return do_instrument;
    }

    // Check if this address starts a slice
    BOOL FoundInStartSlices(ADDRINT addr) const
    {
        PIN_GetLock((PIN_LOCK*)&slicesLock, 1);
        BOOL found = (slices_start_set.find(addr) != slices_start_set.end());
        PIN_ReleaseLock((PIN_LOCK*)&slicesLock);
        return found;
    }
};

#endif

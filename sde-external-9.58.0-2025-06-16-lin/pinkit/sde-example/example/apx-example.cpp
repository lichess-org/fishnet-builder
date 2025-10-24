//
// Copyright (C) 2024-2024 Intel Corporation.
// SPDX-License-Identifier: MIT
//

/*
 * this pin tool show how to use the basic APX APIs
 * specifically to check if instructions are APX or has EGPRs
 *
 * testing done:
 * run the pin tool with Intel APX compiled binary
 *
 */
#include "pin.H"

extern "C"
{
#include "xed-interface.h"
}

#include <iostream>
#include <fstream>
#include <stdio.h>

#include "sde-init.H"
#include "sde-reg-interface.H"

using namespace std;

struct thread_data_t
{
    UINT64 total;
    UINT64 apx;
    UINT64 egprs;
    UINT64 ndd;
    UINT64 reg;

    thread_data_t() : total(0), apx(0), egprs(0), reg(0) {}
};

static KNOB<string> knob_out(KNOB_MODE_WRITEONCE, "pintool", "apx-out", "apx-example.out",
                             "Name of APX example output file name");

static KNOB<BOOL> knob_reg(KNOB_MODE_WRITEONCE, "pintool", "reg", "0", "Track EGPR reg value");

static REG thread_data_reg;
static std::ofstream out;

//=======================================================
//  Analysis routines
//=======================================================

void Count(thread_data_t* td, UINT32 inss, UINT32 apx, UINT32 egprs)
{
    td->total += inss;
    td->apx += apx;
    td->egprs += egprs;
}

void RegApx(thread_data_t* td, CONTEXT* ctxt)
{
    xed_reg_enum_t reg   = XED_REG_R24;
    sde_uint64_t reg_val = 0;
    sde_get_register(ctxt, 0, reg, (sde_uint8_t*)&reg_val, 8);

    if (reg != 0)
    {
        td->reg++;
    }
}

//=======================================================
//  Instrumentationm routines
//=======================================================

bool using_r24(xed_decoded_inst_t* xedd)
{
    const xed_inst_t* xedi           = xed_decoded_inst_inst(xedd);
    const unsigned int operand_count = xed_inst_noperands(xedi);
    for (unsigned int i = 0; i < operand_count; i++)
    {
        const xed_operand_t* operand          = xed_inst_operand(xedi, i);
        const xed_operand_enum_t operand_name = xed_operand_name(operand);
        if (xed_operand_is_register(operand_name))
        {
            xed_reg_enum_t xedreg  = xed_decoded_inst_get_reg(xedd, operand_name);
            xed_reg_enum_t fullreg = xed_get_largest_enclosing_register(xedreg);
            if (fullreg == XED_REG_R24)
            {
                return true;
            }
        }
    }

    return false;
}

VOID Trace(TRACE trace, VOID* v)
{
    for (BBL bbl = TRACE_BblHead(trace); BBL_Valid(bbl); bbl = BBL_Next(bbl))
    {
        UINT32 apx   = 0;
        UINT32 egprs = 0;
        for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins))
        {
            xed_decoded_inst_t* xedd = INS_XedDec(ins);
            if (xed_classify_apx(xedd))
            {
                // This is APX instruction
                apx++;
            }
            if (xed3_operand_get_has_egpr(xedd))
            {
                // This instruction has EGPRs
                egprs++;

                if (knob_reg.Value() && using_r24(xedd))
                {
                    INS_InsertCall(ins, IPOINT_BEFORE, (AFUNPTR)RegApx, IARG_REG_VALUE,
                                   thread_data_reg, IARG_CONST_CONTEXT, IARG_END);
                }
            }
        }

        INS_InsertCall(BBL_InsHead(bbl), IPOINT_BEFORE, (AFUNPTR)Count, IARG_REG_VALUE,
                       thread_data_reg, IARG_UINT32, BBL_NumIns(bbl), IARG_UINT32, apx,
                       IARG_UINT32, egprs, IARG_END);
    }
}

//=======================================================
//  Callback routines
//=======================================================

static VOID ThreadStart(THREADID threadid, CONTEXT* ctxt, INT32 flags, VOID* v)
{
    thread_data_t* td = new thread_data_t();
    PIN_SetContextReg(ctxt, thread_data_reg, (ADDRINT)td);
}

static void ThreadFini(THREADID tid, const CONTEXT* ctxt, INT32 flags, void* v)
{
    thread_data_t* td;
    td = reinterpret_cast<thread_data_t*>(PIN_GetContextReg(ctxt, thread_data_reg));

    out << "Stats for thread: " << tid << std::endl;
    out << "Total instructions: " << td->total << std::endl;
    out << "Apx instructions: " << td->apx << std::endl;
    out << "EGPRs instructions: " << td->egprs << std::endl;

    if (knob_reg.Value())
    {
        out << "Instructions with non zero r24: " << td->reg << std::endl;
    }

    delete td;
}

VOID Fini(INT32 code, VOID* arg)
{
    out << "#eof" << std::endl;
    out.close();
}

/* ===================================================================== */
int main(int argc, char* argv[])
{
    PIN_InitSymbols();

    sde_pin_init(argc, argv);
    sde_init();

    out.open(knob_out.Value().c_str());

    thread_data_reg = PIN_ClaimToolRegister();

    TRACE_AddInstrumentFunction(Trace, 0);

    PIN_AddThreadStartFunction(ThreadStart, 0);
    PIN_AddThreadFiniFunction(ThreadFini, 0);
    PIN_AddFiniFunction(Fini, 0);

    // start program (never returns)
    PIN_StartProgram();

    return 0;
}

//
// Copyright (C) 2004-2025 Intel Corporation.
// SPDX-License-Identifier: MIT
//

#ifndef EMU_H
#define EMU_H

#include "pin.H"

#include "sde-reg-interface.H"
#include "sde-model-specific-features.h"
#include "sde-threads.H"

extern "C"
{
#include "sde-agen.h"
#include "sde-agen-types.h"
}

extern "C"
{
#include "xed-interface.h"
}

class TRACER_ENTRY;

class EMU_ISA
{
  public:
    static BOOL IsAgen(const INS ins);
    static BOOL IsAgenAndNative(const INS ins);
    static BOOL IsAgenRead(const THREADID pin_tid);
    static BOOL IsAgenCET(const INS ins);

    static VOID FillMemTrace(THREADID pin_tid, TRACER_ENTRY& tracer_entry);

    static BOOL IsPageReadOnly(ADDRINT addr);

    static BOOL IsEmulatedReg(xed_reg_enum_t xed_reg, xed_reg_class_enum_t rclass);
    static VOID GetEmulatedReg(UINT8* value, THREADID pin_tid, xed_reg_enum_t xed_reg);
    static VOID SetEmulatedReg(UINT8* value, THREADID pin_tid, xed_reg_enum_t xed_reg);
};

#endif

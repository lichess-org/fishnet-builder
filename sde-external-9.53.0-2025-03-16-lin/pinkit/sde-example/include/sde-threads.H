//
// Copyright (C) 2024-2024 Intel Corporation.
// SPDX-License-Identifier: MIT
//

#if !defined(_SDE_THREADS_H_)
#define _SDE_THREADS_H_
#include "pin.H"

// Those values are taken from PIN3 because in PIN4 this value is 64K
// SDE-4248
#if (defined(TARGET_IA32) || !(defined(TARGET_LINUX) || defined(TARGET_WINDOWS)))
const UINT32 SDE_MAX_THREADS = 2048;
#else
const UINT32 SDE_MAX_THREADS = 8192;
#endif

#endif

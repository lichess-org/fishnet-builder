/*
 * Copyright (C) 2013-2021 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#include <cassert>
#include <string>
#include <cstring>
#include <sstream>
#include "regvalue_utils.h"







/////////////////////
// EXTERNAL FUNCTIONS
/////////////////////

extern "C" bool ProcessorSupportsAvx();
extern "C" bool SupportsAvx512f();

/////////////////////
// GLOBAL VARIABLES
/////////////////////

// Boolean indicating whether the system supports AVX instructions and registers.
const bool hasAvxSupport     = ProcessorSupportsAvx();
const bool hasAvx512fSupport = SupportsAvx512f();

/////////////////////
// INTERNAL FUNCTIONS IMPLEMENTATION
/////////////////////

template< typename SIZETYPE >
static bool CompareSizedWord(const unsigned char* value, const unsigned char* expected, unsigned int element,
                             unsigned int totalSize,std::ostream& ost)
{
    if (*((SIZETYPE*)(&value[element << 3])) != *((SIZETYPE*)(&expected[element << 3])))
    {
        ost << "WARNING: Expected value: " << Val2Str((void*)expected, totalSize) << std::endl << std::flush;
        ost << "WARNING: Received value: " << Val2Str((void*)value, totalSize) << std::endl << std::flush;
        return false;
    }
    return true;
}

/////////////////////
// API FUNCTIONS IMPLEMENTATION
/////////////////////

std::string Val2Str(const void* value, unsigned int size)
{
    std::stringstream sstr;
    sstr << std::hex;
    const unsigned char* cval = (const unsigned char*)value;
    // Traverse cval from end to beginning since the MSB is in the last block of cval.
    while (size)
    {
        --size;
        sstr << (unsigned int)cval[size];
    }
    return std::string("0x") + sstr.str();
}

bool CompareValues(const void* value, const void* expected, unsigned int size,std::ostream& ost)
{
    if (0 != memcmp(value, expected, size))
    {
        ost << "WARNING: Expected value: " << Val2Str(expected, size) << std::endl << std::flush;
        ost << "WARNING: Received value: " << Val2Str(value, size) << std::endl << std::flush;
        return false;
    }
    return true;
}

void AssignNewPinRegisterValue(PINTOOL_REGISTER* pinreg, const UINT64* newval, UINT qwords)
{
    static UINT maxQwords = sizeof(PINTOOL_REGISTER) / sizeof(UINT64);
    assert(qwords <= maxQwords);
    for (UINT i = 0; i < qwords; ++i)
    {
        pinreg->qword[i] = newval[i];
    }
}

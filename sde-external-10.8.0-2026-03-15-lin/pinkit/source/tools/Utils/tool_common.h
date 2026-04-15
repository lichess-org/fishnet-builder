/*
 * Copyright (C) 2023-2023 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

#ifndef TOOL_COMMON_H
#define TOOL_COMMON_H

#include "pin.H"

#if defined(TARGET_LINUX)
#include <sys/syscall.h>
#include <unistd.h>
#include <sys/utsname.h>


/*!
 * Read OS release number into the specified buffer.
 * Return True if the release number was written to specified buffer, false in all other cases.
 */
static inline bool UtilsGetKernelRelease(CHAR* buf, USIZE bufsize)
{
    struct utsname uname;
    // t_syscall_arg unameArgs[] = {(t_syscall_arg)&uname};
    // if (0 != syscall(SYS_native_syscall_unsafe, __NR_uname, 0, 1, unameArgs))
    // {
    //     return false;
    // }

    auto ret = OS_Syscall_unsafe(__NR_uname, &uname);
    if (IS_PINOS_SYSCALL_ERROR(ret))
    {
        return false;
    }

    if (bufsize < (strlen(uname.release) + 1))
    {
        return false;
    }

    strcpy(buf, uname.release);

    return true;
}

#endif // if defined(TARGET_LINUX)

/*
 * Since we removed MemRange class from public header, this is a minimal version for pintools to use.
 * Class that represents a memory range - interval of addresses in the virtual
 * address space.
 */
class MemRange
{
  public:
    //Default constructor
    MemRange() : m_base(NULL), m_size(0) {}
    //Construct range with a given base and end addresses.
    //End address of a range is the address of the first byte following the range
    MemRange(VOID* base, VOID* end) : m_base(base), m_size(PtrDiff(end, base)) {}

    /*
    * Check to see whether this range contains the specified memory address
    *
    * @param[in] addr       memory address, potentially contained in this range
    *
    * @return   true, if this range contains the specified address,
    *           otherwise - false
    */
    BOOL Contains(const VOID* addr) const { return (PtrDiff(addr, m_base) < m_size); }

  private:
    VOID* m_base;
    size_t m_size;
};

#endif // TOOL_COMMON_H

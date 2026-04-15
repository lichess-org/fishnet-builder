/*
 * Copyright (C) 2025-2025 Intel Corporation.
 * SPDX-License-Identifier: MIT
 */

.type SupportsApx, @function
.global SupportsApx
SupportsApx:

    push    %rbp
    mov     %rsp, %rbp
    push    %rbx
    push    %rcx
    push    %rdx

    // First check if XSAVE and OSXSAVE are supported
    mov     $1, %rax
    cpuid
    andq    $0x0c000000, %rcx
    cmpq    $0x0c000000, %rcx    // check both OSXSAVE and XSAVE feature flags
    jne     NotSupported
    
    // Check if OS has enabled APX state support (bit 19 in XCR0)
    mov     $0, %rcx       // specify 0 for XFEATURE_ENABLED_MASK register
    .byte   0xf, 0x1, 0xd0 // xgetbv - result in EDX:EAX
    andq    $0x80000, %rax // check bit 19 (1<<19 = 0x80000)
    jz      NotSupported   // OS hasn't enabled APX state support

    mov     $7, %rax
    mov     $1, %rcx       // Check for APX support on CPU (EAX=7, ECX=1)
    cpuid
    andq    $0x200000, %rdx // bit 21 apx
    jz      NotSupported    // no APX
    mov     $1, %rax
done:
    pop     %rdx
    pop     %rcx
    pop     %rbx
    leave
    ret

NotSupported:
    mov     $0, %rax
    jmp     done

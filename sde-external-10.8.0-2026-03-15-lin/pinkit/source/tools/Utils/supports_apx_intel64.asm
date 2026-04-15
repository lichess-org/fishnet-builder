;
; Copyright (C) 2025-2025 Intel Corporation.
; SPDX-License-Identifier: MIT
;

PUBLIC SupportsApx

.code
SupportsApx PROC
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx

    ; First check if XSAVE and OSXSAVE are supported
    mov     rax, 1
    cpuid
    and     rcx, 00c000000h
    cmp     rcx, 00c000000h ; check both OSXSAVE and XSAVE feature flags
    jne     $lNotSupported
    
    ; Check if OS has enabled APX state support (bit 19 in XCR0)
    mov     rcx, 0          ; specify 0 for XFEATURE_ENABLED_MASK register
    BYTE    00Fh            ; xgetbv - result in EDX:EAX
    BYTE    001h
    BYTE    0D0h
    
    and     rax, 080000h    ; check bit 19 (1<<19 = 0x80000)
    jz      $lNotSupported  ; OS hasn't enabled APX state support

    ; Check for APX support on CPU
    mov     rax, 7
    mov     rcx, 1          ; Check for APX support on CPU (EAX=7, ECX=1)
    cpuid
    and     rdx, 0200000h   ; bit 21 apx
    jz      $lNotSupported  ; no APX
    mov     rax, 1
    jmp     $ldone

$lNotSupported:
    mov     rax, 0
    jmp     $ldone

$ldone:
    pop     rdx
    pop     rcx
    pop     rbx

    mov     rsp, rbp
    pop     rbp
    ret


SupportsApx ENDP

end

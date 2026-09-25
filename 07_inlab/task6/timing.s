; timing.s: time one counting loop with rdtsc and with the clock_gettime
; syscall, then work out how many rdtsc ticks make one microsecond.
;
; Build and run: make task6      (from the 07_inlab folder)

section .data
    fmt_tsc:    db "rdtsc ticks      : %lu", 10, 0
    fmt_mhz:    db "tsc MHz          : %lu   (ticks per microsecond)", 10, 0
    fmt_tsc_ns: db "tsc_ns           : %.0f", 10, 0
    fmt_ns:     db "clock_gettime_ns : %ld", 10, 0

section .bss
    ts0:    resq 2          ; struct timespec: [0]=tv_sec, [8]=tv_nsec
    ts1:    resq 2
    tsc:    resq 1          ; tick difference, kept in memory across calls
    ns:     resq 1

section .text
    global main
    extern printf

; READ_TSC: rax = time stamp counter.
; rdtsc puts the low 32 bits in eax and the high 32 bits in edx
; (writing eax/edx zeroes the upper halves of rax/rdx), so combine them.
; lfence first: the CPU may run instructions out of order, and lfence makes
; rdtsc wait until every earlier instruction has finished. Without it the
; reading can land before the loop it should time has really completed.
; (rdtscp does a similar job in one instruction. Details are in the slides.)
%macro READ_TSC 0
    lfence
    rdtsc
    shl rdx, 32
    or  rax, rdx
%endmacro

; GET_TIME ptr: clock_gettime(CLOCK_MONOTONIC, ptr)
; Syscall registers: number in rax; args in rdi, rsi, rdx, r10, r8, r9.
; (r10, not rcx, is the 4th arg.) The syscall instruction itself
; overwrites rcx and r11, so do not keep anything live in them.
%macro GET_TIME 1
    mov rax, 228            ; clock_gettime
    mov rdi, 1              ; CLOCK_MONOTONIC
    lea rsi, [rel %1]       ; struct timespec *
    syscall
%endmacro

main:
    push r12                ; r12 is callee-saved and we use it below; the push also
                            ; makes rsp 16-aligned for printf (it is 8 mod 16 on entry)

    ; Both clocks wrap the same loop. The ns window is the outer one, so it
    ; also covers the two rdtsc instructions (a few ns, invisible in ms).
    GET_TIME ts0
    READ_TSC
    mov r12, rax            ; r12 = start ticks (syscall only changes rax, rcx, r11)
    mov rcx, 100000000
.loop:
    dec rcx
    jnz .loop
    READ_TSC
    sub rax, r12
    mov [rel tsc], rax      ; ticks = end - start
    GET_TIME ts1

    ; ns = (sec1 - sec0) * 1e9 + (nsec1 - nsec0)
    mov rax, [rel ts1]
    sub rax, [rel ts0]
    imul rax, 1000000000
    add rax, [rel ts1 + 8]
    sub rax, [rel ts0 + 8]
    mov [rel ns], rax

    lea rdi, [rel fmt_tsc]
    mov rsi, [rel tsc]
    xor eax, eax            ; al = 0: no SSE args for variadic printf
    call printf

    ; MHz = ticks * 1000 / ns   (ns is nanoseconds, so ticks/ns is GHz)
    mov rax, [rel tsc]
    imul rax, 1000
    xor edx, edx            ; div takes rdx:rax as the dividend
    div qword [rel ns]      ; rax = ticks * 1000 / ns
    mov rsi, rax
    lea rdi, [rel fmt_mhz]
    xor eax, eax
    call printf

    ; tsc_ns = ticks / MHz * 1000, in double precision so the truncated integer
    ; MHz above does not spoil the result. printf takes the double in xmm0.
    cvtsi2sd xmm0, qword [rel tsc]  ; xmm0 = ticks
    cvtsi2sd xmm1, qword [rel ns]   ; xmm1 = clock_gettime ns
    mov eax, 1000
    cvtsi2sd xmm2, eax              ; xmm2 = 1000.0
    movapd xmm3, xmm0
    mulsd xmm3, xmm2
    divsd xmm3, xmm1                ; xmm3 = MHz = ticks * 1000 / ns
    divsd xmm0, xmm3
    mulsd xmm0, xmm2                ; xmm0 = tsc_ns
    lea rdi, [rel fmt_tsc_ns]
    mov eax, 1              ; al = 1: one SSE argument for variadic printf
    call printf

    lea rdi, [rel fmt_ns]
    mov rsi, [rel ns]
    xor eax, eax
    call printf

    pop r12
    xor eax, eax            ; return 0 from main
    ret

section .note.GNU-stack noalloc noexec nowrite progbits ; no executable stack

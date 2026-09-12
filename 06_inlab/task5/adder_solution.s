extern printf
extern exit                  ; libc exit, NOT syscall 60

; .rodata = read-only data, such as string constants
section .rodata
    fmt: db "sum = %ld", 10, 0

; .bss = uninitialized storage; reserves space without storing initial data
section .bss
    inbuf: resb 256

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    xor eax, eax              ; total = 0
    xor ecx, ecx              ; i = 0

.loop:
    cmp rcx, rsi              ; if i >= len, exit
    jae .done

    movzx edx, byte [rdi + rcx]
    sub dl, '0'
    cmp dl, 9
    ja .done                  ; if (uint8_t)d > 9, exit

    imul rax, 10              ; total *= 10
    add rax, rdx              ; total += digit

    inc rcx
    jmp .loop

.done:
    ret

; HELPER FUNCTION!
; my_readline(char* buf{rdi}, size_t len{rsi}) -> size_t{rax}
my_readline:
    mov rdx, rsi              ; number of bytes to read
    mov rsi, rdi              ; buf
    xor eax, eax              ; syscall: read
    xor edi, edi              ; fd = 0 (stdin)
    syscall
    ret

_start:
    ; IMPORTANT: libc requires 16-byte stack alignment before a call.
    ; rsp must be 16-byte aligned here.
    ;
    ; General rule: every push subtracts 8 from rsp, every pop adds 8.
    ; Therefore, an even number of pushes/pops preserves 16-byte alignment;
    ; an odd number flips it.
    and rsp, -16

    lea rdi, [inbuf]
    mov rsi, 256
    call my_readline

    lea rdi, [inbuf]
    mov rsi, rax
    call my_atoi
    mov r12, rax              ; first number

    lea rdi, [inbuf]
    mov rsi, 256
    call my_readline

    lea rdi, [inbuf]
    mov rsi, rax
    call my_atoi              ; second number

    add rax, r12              ; sum

    lea rdi, [fmt]            ; first printf argument: format
    mov rsi, rax              ; second argument: sum

    ; IMPORTANT: for variadic functions like printf, AL must contain
    ; the number of XMM registers used for floating-point arguments.
    ; We have none, so AL = 0.
    xor eax, eax

    call printf

    xor edi, edi              ; exit status = 0
    call exit
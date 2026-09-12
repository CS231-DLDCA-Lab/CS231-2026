extern printf
extern exit

section .rodata
    fmt: db "%ld:%02ld:%02ld", 10, 0

section .bss
    buf: resb 256

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}   -- GIVEN, do not edit
my_atoi:
    xor eax, eax
    xor ecx, ecx
.loop:
    cmp rcx, rsi
    jae .done
    movzx edx, byte [rdi + rcx]
    sub dl, '0'
    cmp dl, 9
    ja .done
    lea rax, [rax + rax*4]
    lea rax, [rax*2 + rdx]
    inc rcx
    jmp .loop
.done:
    ret

_start:
    and rsp, -16

    ; read one line from stdin, parse the total-seconds number
    xor eax, eax          ; read
    xor edi, edi          ; fd 0
    lea rsi, [buf]
    mov rdx, 256
    syscall
    lea rdi, [buf]
    mov rsi, rax          ; len = bytes read
    call my_atoi          ; rax = T

    ; H = T / 3600, leftover = T % 3600
    xor edx, edx          ; clear high half before div
    mov rcx, 3600
    div rcx               ; rax = H, rdx = leftover seconds
    mov r12, rax          ; H

    ; M = leftover / 60, S = leftover % 60
    mov rax, rdx
    xor edx, edx          ; clear high half again
    mov rcx, 60
    div rcx               ; rax = M, rdx = S
    mov r13, rdx          ; S (save before rdx is reused as a printf arg)

    ; printf("%ld:%02ld:%02ld\n", H, M, S)
    lea rdi, [fmt]
    mov rsi, r12          ; H
    mov rdx, rax          ; M
    mov rcx, r13          ; S
    xor eax, eax          ; 0 vector-register args
    call printf

    xor edi, edi
    call exit

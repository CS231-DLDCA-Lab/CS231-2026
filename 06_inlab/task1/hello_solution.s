section .data
    greeting: db "Hello "
    greeting_len equ $ - greeting
    buf: times 512 db 0          ; sits right after greeting, so the two are contiguous

section .text
    global _start

_start:
    xor eax, eax          ; read
    xor edi, edi          ; fd 0
    lea rsi, [buf]
    mov rdx, 512
    syscall               ; rax = bytes read

    lea rdx, [rax + greeting_len]  ; "Hello " + input, one contiguous run
    mov rax, 1            ; write
    mov rdi, 1            ; fd 1
    lea rsi, [greeting]
    syscall

    mov rax, 60
    xor edi, edi
    syscall

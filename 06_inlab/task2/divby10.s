section .text
    global _start

; div_by_10(uint64_t n{rdi}) -> uint64_t{rax}
div_by_10:
    ; TODO

    ret

_start:
    ; TODO: call div_by_10(250), exit with the result

    mov rax, 60
    xor edi, edi
    syscall

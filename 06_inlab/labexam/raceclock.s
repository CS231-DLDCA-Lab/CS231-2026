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

    ; TODO:
    ;  - read one line from stdin, call my_atoi -> T (total seconds)
    ;  - H = T / 3600 ; then split the remainder with / 60 into M and S
    ;  - printf(fmt, H, M, S)   ; fmt is "%ld:%02ld:%02ld\n" above
    ;  - exit(0)
    ; div note: clear rdx (xor edx, edx) before EVERY div.
    ; printf note: clear rax (xor eax, eax) before EVERY printf call.
    ; Also if you are using stack for storing variables dont forget about
    ; the 16-byte alignment before calling libc function call.

    xor edi, edi
    call exit

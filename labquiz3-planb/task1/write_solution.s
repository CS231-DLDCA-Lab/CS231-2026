global my_write
global my_exit
section .text

my_write:
    mov     rdx, rsi            ; len
    mov     rsi, rdi            ; buf
    mov     rdi, 1              ; stdout
    mov     rax, 1              ; write
    syscall
    ret

my_exit:
    mov     rax, 60             ; exit, code already in rdi
    syscall

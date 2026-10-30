section .data
    buf: times 512 db 0

section .text
    global _start

_start:
    ; TODO: read a line from stdin (fd 0), then print "Hello " followed by the
    ;       bytes you read to stdout (fd 1) using a SINGLE write syscall. Exit 0.

    mov rax, 60
    xor edi, edi
    syscall

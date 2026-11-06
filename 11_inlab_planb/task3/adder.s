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
;   total = 0; for each byte: d = byte - '0'; stop if d > 9; total = total*10 + d
my_atoi:
    ; TODO

    ret

; ==================== DO NOT EDIT BELOW THIS LINE ====================
; my_readline(char* buf{rdi}, size_t len{rsi}) -> size_t{rax}
;   Reads one line from stdin into buf. Returns the number of bytes read.
my_readline:
    mov rdx, rsi              ; number of bytes to read
    mov rsi, rdi              ; buf
    xor eax, eax              ; syscall: read
    xor edi, edi              ; fd = 0 (stdin)
    syscall
    ret
; ==================== DO NOT EDIT ABOVE THIS LINE ====================

_start:
    ; TODO:
    ;   1. and rsp, -16
    ;   2. my_readline(inbuf, 256), then my_atoi(inbuf, rax); keep it in r12
    ;   3. the same for the second number, then add r12
    ;   4. printf(fmt, sum) with al = 0

    xor edi, edi              ; exit status = 0
    call exit                 ; libc exit: flushes printf's output, then exits

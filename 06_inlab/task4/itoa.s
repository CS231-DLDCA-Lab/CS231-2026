section .bss
    inbuf:  resb 256
    outbuf: resb 32

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    ; TODO: copy your Task 3 solution here

    ret

; ----------------------------------------------------------------------------
; my_itoa(uint64_t n{rdi}, char* buf{rsi}) -> size_t{rax}   -- GIVEN, do not edit
;   Writes the decimal text of n into buf (no null terminator). Returns the
;   number of digits written. Digits fall out of the div-by-10 loop least
;   significant first, so we fill buf forwards and then reverse it in place.
; ----------------------------------------------------------------------------
my_itoa:
    mov rax, rdi
    mov r8, rsi          ; write pointer
    mov r9, 10
.emit:
    xor edx, edx
    div r9              ; rax = rax/10, rdx = rax%10
    add dl, '0'
    mov [r8], dl
    inc r8
    test rax, rax
    jnz .emit

    mov rax, r8
    sub rax, rsi         ; rax = number of digits

    dec r8               ; last digit
.reverse:
    cmp rsi, r8
    jae .done
    mov cl, [rsi]
    mov dl, [r8]
    mov [rsi], dl
    mov [r8], cl
    inc rsi
    dec r8
    jmp .reverse
.done:
    ret

_start:
    ; TODO: read two lines from stdin, my_atoi each, add them, my_itoa the sum
    ;       into outbuf, write the digits + a newline to stdout, exit 0.

    mov rax, 60
    xor edi, edi
    syscall

; .bss = Block Started by Symbol
; It's the section where you reserve space for uninitialized data
section .bss
    inbuf:  resb 512

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    xor eax, eax          ; total
    xor ecx, ecx          ; i
.loop:
    cmp rcx, rsi          
    jae .done             

    movzx edx, byte [rdi + rcx]
    sub dl, '0'
    cmp dl, 9
    ja .done
    
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .loop
.done:
    ret

; ----------------------------------------------------------------------------
; my_itoa(uint64_t n{rdi}, char* buf{rsi}) -> size_t{rax}   -- GIVEN, do not edit
; You don't need to learn this function fully; these comments are just for
; understanding what the given code is doing.
; ----------------------------------------------------------------------------
my_itoa:
    mov rax, rdi              ; rax = number
    mov r8, rsi               ; r8 = current position in buffer
    mov r9, 10                ; divisor = 10

.emit:
    xor edx, edx              ; clear rdx before 128-bit division
    div r9                     ; rax = number / 10, rdx = number % 10
    add dl, '0'                ; convert remainder to ASCII digit
    mov [r8], dl               ; store digit
    inc r8                     ; move to next buffer position
    test rax, rax              ; is quotient zero?
    jnz .emit                 ; no -> extract another digit

    ; Digits were generated backwards, so reverse them.
    mov rax, r8                ; rax = end of string
    sub rax, rsi               ; rax = number of digits

    dec r8                     ; point to last digit
.reverse:
    cmp rsi, r8                ; have the pointers met?
    jae .done
    mov cl, [rsi]              ; swap first and last characters
    mov dl, [r8]
    mov [rsi], dl
    mov [r8], cl
    inc rsi                    ; move toward the middle
    dec r8
    jmp .reverse
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
    lea rdi, [inbuf]
    mov rsi, 512
    call my_readline
    mov r13, rax              ; length of first line

    ; Q: Why am I using r12 and r13 here? Instead of r8, r9?

    lea rdi, [inbuf]
    mov rsi, r13
    call my_atoi
    mov r12, rax              ; first number

    lea rdi, [inbuf]
    mov rsi, 512
    call my_readline

    lea rdi, [inbuf]
    mov rsi, rax
    call my_atoi              ; second number

    add rax, r12              ; sum = first + second

    ; exit(sum)
    mov rdi, rax              ; exit status = sum
    mov rax, 60               ; syscall: exit
    syscall

    ; A: r12-15 are callee-saved!!! can use them freely inside _start because this is the top level function
; extern dump_regs ; allows you to compile this with dump_regs.s and use the function here

section .text
    global _start

; receives arguments in rdi, rsi, rdx, rcx, ...
adder:
    ; PROLOGUE: push callee-saved regs - rbx,rsp,rbp,r12-15
    push rbx
    push r12

    ; do work!!
    ; here i can tamper with rbx
    mov rbx, rdi
    add rbx, rsi
    mov rax, rbx ; finally store return value in rax

    ; EPILOGUE: pop callee-saved regs - rbx,rsp,rbp,r12-15
    pop r12
    pop rbx

    ret

_start:
    ; GOAL: compute adder(10, 20) * 3 - 10

    mov rdi, 10 ; rdi - caller saved
    mov rbx, 3  ; rbx - callee saved

    ; PRE-CALL WORK : push caller-saved regs - rax,rdi,rsi,rdx,rcx,r8-11,xmm*
    ; Q1: Why am I not pushing rax? See below at NOTE1
    push rdi
    push rsi
    push rdx
    ; ...

    mov rdi, 10   ; put arguments in rdi, rsi...
    mov rsi, 20
    call adder    ; answer is put in rax
    
    ; POST-CALL WORK: pop caller-saved regs
    pop rdx
    pop rsi
    pop rdi
    ; recover old rdi, rsi, rdx values

    ; NOTE1: Does this usage give you the answer to Q1?
    imul rax, rbx ; rax *= rbx (rbx is untouched by `adder`, the callee)
    sub rax, rdi  ; rax -= rdi (rdi is pushed/popped by me , the caller)
    mov r12, rax  ; stash it away in r12, r12 is my returncode value

    ; answer (came in `rax`) should sit in `rdi`
    ; for setting returncode in syscall
    mov rdi, r12
    mov rax, 60
    syscall

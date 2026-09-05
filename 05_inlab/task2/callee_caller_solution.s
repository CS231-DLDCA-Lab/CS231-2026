extern dump_regs

section .data
    ;; func_caller() should come out to 90

section .text
    global _start

; func_callee(rdi = a, rsi = b) -> rax = a + b
;
; To make this exercise meaningful, once you've computed the sum, deliberately
; overwrite every OTHER caller-saved register (rcx, rdx, rsi, rdi, r8, r9,
; r10, r11) with any junk value you like. This models a "worst case" callee
; that gives you no guarantees beyond what the ABI actually promises.
func_callee:
    push r12
    lea r12, [rdi + rsi]   ; stash the sum somewhere safe before trashing everything

    mov rcx, 0xdead
    mov rdx, 0xbeef
    mov rsi, 0xcafe
    mov rdi, 0xf00d
    mov r8, 1
    mov r9, 2
    mov r10, 3
    mov r11, 4

    mov rax, r12
    pop r12
    ret

; func_caller() -> rax
; Calls func_callee(10, 20), and also needs a multiplier of 3 to survive the
; call so it can compute func_callee's result * 3 afterward.
;
; Call dump_regs() once right before calling func_callee, and once right
; after it returns, so you can compare the two snapshots.
func_caller:
    push rbx
    mov rbx, 3              ; multiplier -- must survive func_callee's call

    call dump_regs

    mov rdi, 10
    mov rsi, 20
    call func_callee

    call dump_regs

    imul rax, rbx
    pop rbx
    ret

_start:
;   Call func_caller() and exit with the result.
    call func_caller
    mov rdi, rax
    mov rax, 60
    syscall

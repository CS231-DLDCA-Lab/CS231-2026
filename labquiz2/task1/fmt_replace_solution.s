    global fmt_replace

section .text

; fmt_replace(const char* fmt{rdi}, const char* arg{rsi},
;             char* out{rdx}, size_t cap{rcx}) -> size_t{rax}
;
; Copies fmt into out, writing the whole string arg in place of every '%'.
; out has room for cap bytes, and one of them is needed for the final NUL,
; so at most cap - 1 characters are written. Returns how many were written.
fmt_replace:
    xor     eax, eax                ; n = characters written so far
    test    rcx, rcx
    jz      .done                   ; cap = 0: no room even for the NUL
    dec     rcx                     ; rcx = cap - 1 = most characters we may write

.next_fmt:
    cmp     rax, rcx
    jae     .terminate              ; jae = n >= cap - 1: out is full, nothing more fits
    movzx   r8d, byte [rdi]         ; c = *fmt (movzx clears the upper bits of r8)
    test    r8b, r8b
    jz      .terminate              ; c = 0: end of fmt
    inc     rdi                     ; fmt++
    cmp     r8b, '%'
    je      .copy_arg
    mov     [rdx + rax], r8b        ; out[n] = c
    inc     rax                     ; n++
    jmp     .next_fmt

.copy_arg:
    mov     r9, rsi                 ; p = arg; start from the beginning for each '%'
.next_arg:
    movzx   r8d, byte [r9]          ; c = *p
    test    r8b, r8b
    jz      .next_fmt               ; end of arg: back to fmt
    cmp     rax, rcx
    jae     .terminate              ; out is full
    mov     [rdx + rax], r8b        ; out[n] = c
    inc     rax                     ; n++
    inc     r9                      ; p++
    jmp     .next_arg

.terminate:
    mov     byte [rdx + rax], 0     ; out[n] = 0; n <= cap - 1, so this is inside out
.done:
    ret                             ; rax = n

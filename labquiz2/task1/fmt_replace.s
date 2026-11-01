    global fmt_replace

section .text

; fmt_replace(const char* fmt{rdi}, const char* arg{rsi},
;             char* out{rdx}, size_t cap{rcx}) -> size_t{rax}
;
; Copies fmt into out, writing the whole string arg in place of every '%'.
; out has room for cap bytes, and one of them is needed for the final NUL,
; so at most cap - 1 characters are written. Returns how many were written.
;
; Outline:
;   n = 0; if cap is 0, return 0 without writing anything
;   for each character c of fmt (stop at the NUL):
;       c != '%': copy c to out[n], n++
;       c == '%': copy each character of arg to out[n], n++
;       stop as soon as out holds cap - 1 characters
;   out[n] = 0, return n
fmt_replace:
    ; TODO

    ret

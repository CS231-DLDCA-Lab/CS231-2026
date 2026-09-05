; ---- LEAF CALLEE: borrows rbx as scratch -> must save/restore it ----
scale_add(float, float):
        push    rbx        ; PROLOGUE: push rbx on stack
        mov     ebx, 3     ; ebx = 3   (just using rbx as scratch space)
        cvtsi2ss xmm2, ebx ; xmm2 = 3.0
        mulss   xmm0, xmm2 ; xmm0 = a * 3.0
        addss   xmm0, xmm1 ; xmm0 += b     -> return value in xmm0
        pop     rbx        ; EPILOGUE: restore rbx
        ret

; ---- CALLER ----
sum_loop(float*, int):
        xorps   xmm0, xmm0 ; total = 0.0, kept directly in xmm0
        mov     r12d, 0    ; i = 0
.loop_check:
        cmp     r12d, esi             ; i vs n (n is chilling in rsi)
        jge     .loop_end
        push    rdi                   ; PRE-CALL WORK: save 'arr'
        push    rsi                   ; PRE-CALL WORK: save 'n'
        push    r12                   ; PRE-CALL WORK: save 'i'
        sub     rsp, 8                ; PRE-CALL WORK: make room on stack for 'total'
        movss   dword ptr [rsp], xmm0 ; PRE-CALL WORK: save 'total'

        ; setup call
        movss   xmm0, dword ptr [rdi + 4*r12] ; xmm0 = arr[i]   (arg 1 for scale_add)
        cvtsi2ss xmm1, r12d                   ; xmm1 = (float)i (arg 2 for scale_add)
        call    scale_add(float, float)

        addss   xmm0, dword ptr [rsp] ; POST-CALL WORK: total += return value
        add     rsp, 8                ; POST-CALL WORK: free stack slot used for 'total'
        pop     r12                   ; POST-CALL WORK: restore 'i'
        pop     rsi                   ; POST-CALL WORK: restore 'n'
        pop     rdi                   ; POST-CALL WORK: restore 'arr'
        inc     r12d                  ; i++
        jmp     .loop_check
.loop_end:
        ret          ; total is already sitting in xmm0, nothing more to do
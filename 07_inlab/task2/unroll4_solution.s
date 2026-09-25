; unroll4_solution.s -- loop.s unrolled by 4.
;
; One iteration handles elements i .. i+3: the body of loop.s is repeated
; 4 times with its own registers and offsets, and the pointers and the
; counter are updated once per iteration. N must be a multiple of 4.

        .data
n:      .word 8                  ; N, the number of elements
a:      .word 3, 10, 17, 24, 31, 38, 45, 52
b:      .word 5, 18, 31, 44, 57, 70, 83, 96
c:      .space 64                ; N words, filled in by the program

        .text
        ; ---- setup: DO NOT EDIT ----
        ld    r4, n(r0)          ; r4 = N, the number of elements left
        daddi r1, r0, a          ; r1 -> a[0]
        dsll  r5, r4, 3          ; r5 = 8 * N, the size of one array in bytes
        dadd  r2, r1, r5         ; r2 -> b[0]  (b follows a in memory)
        dadd  r3, r2, r5         ; r3 -> c[0]  (c follows b)
        ; ---- end of setup ----

loop:   ld    r5, 0(r1)          ; a[i]
        ld    r6, 0(r2)          ; b[i]
        dadd  r7, r5, r6         ; a[i] + b[i]
        sd    r7, 0(r3)          ; c[i]
        ld    r8, 8(r1)          ; a[i+1]
        ld    r9, 8(r2)          ; b[i+1]
        dadd  r10, r8, r9        ; a[i+1] + b[i+1]
        sd    r10, 8(r3)         ; c[i+1]
        ld    r11, 16(r1)        ; a[i+2]
        ld    r12, 16(r2)        ; b[i+2]
        dadd  r13, r11, r12      ; a[i+2] + b[i+2]
        sd    r13, 16(r3)        ; c[i+2]
        ld    r14, 24(r1)        ; a[i+3]
        ld    r15, 24(r2)        ; b[i+3]
        dadd  r16, r14, r15      ; a[i+3] + b[i+3]
        sd    r16, 24(r3)        ; c[i+3]
        daddi r1, r1, 32         ; advance the pointers by 4 elements ...
        daddi r2, r2, 32
        daddi r3, r3, 32
        daddi r4, r4, -4         ; ... and the counter by 4
        bne   r4, r0, loop       ; repeat while elements are left

        syscall 0                ; stop the simulator

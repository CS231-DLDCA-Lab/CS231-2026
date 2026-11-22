; fast_solution.s -- 13326 cycles for N = 1024 (loop.s: 21518).
; 5a + b = 4a + (a + b); the address and counter updates fill the gaps.

        .data
n:      .word 8                  ; N, the number of elements
a:      .word 11, 48, 85, 122, 159, 196, 233, 270
b:      .word 7, 60, 113, 166, 219, 272, 325, 378
c:      .space 64                ; N words, written by the program

        .text
        ; ---- setup: DO NOT EDIT ----
        ld    r4, n(r0)          ; r4 = N, the number of elements left
        daddi r1, r0, a          ; r1 -> a[0]
        dsll  r5, r4, 3          ; r5 = 8 * N, the size of one array in bytes
        dadd  r2, r1, r5         ; r2 -> b[0]  (b follows a in memory)
        dadd  r3, r2, r5         ; r3 -> c[0]  (c follows b)
        ; ---- end of setup ----

loop:   ld    r5, 0(r1)
        ld    r6, 0(r2)
        daddi r3, r3, 8
        dsll  r7, r5, 2          ; 4a
        dadd  r8, r5, r6         ; a + b
        daddi r1, r1, 8
        daddi r2, r2, 8
        dadd  r7, r7, r8
        daddi r4, r4, -1
        sd    r7, -8(r3)         ; r3 already moved on
        bne   r4, r0, loop

        ; ---- end: DO NOT EDIT ----
        syscall 0                ; stop the simulator

; unroll_solution.s -- 9741 cycles for N = 1023 (loop.s: 21497).
; Loads, shifts, adds, stores; the updates fill the gaps. No stalls.

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

        slti  r20, r4, 2
        bne   r20, r0, one

loop:   ld    r5, 0(r1)
        ld    r6, 8(r1)
        ld    r7, 0(r2)
        ld    r8, 8(r2)
        dsll  r9, r5, 2
        dsll  r10, r6, 2
        daddi r4, r4, -2
        dadd  r9, r9, r5
        dadd  r10, r10, r6
        daddi r1, r1, 16
        dadd  r9, r9, r7
        dadd  r10, r10, r8
        daddi r2, r2, 16
        slti  r20, r4, 2
        sd    r9, 0(r3)
        sd    r10, 8(r3)
        daddi r3, r3, 16
        beq   r20, r0, loop

one:    beq   r4, r0, done
        ld    r5, 0(r1)
        ld    r6, 0(r2)
        dsll  r7, r5, 2
        dadd  r7, r7, r5
        dadd  r7, r7, r6
        sd    r7, 0(r3)
done:
        ; ---- end: DO NOT EDIT ----
        syscall 0                ; stop the simulator

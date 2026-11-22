; fast.s -- Q4 Part A: the loop of loop.s, reordered               (TODO)

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

        ; TODO: copy lines 26-36 of loop.s here (from "loop:" to "bne"), then reorder them

        ; ---- end: DO NOT EDIT ----
        syscall 0                ; stop the simulator

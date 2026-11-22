; unroll.s -- Q4 Part B: unrolled by 2, leftover done alone        (TODO)

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

        ; TODO: write 2x unrolled code and optimize it: some hints are given for you

        ; TODO: if n < 2, go to one else proceed into loop...

loop:   ld    r5, 0(r1)
        ld    r6, 8(r1)
        ld    r7, 0(r2)
        ld    r8, 8(r2)
        ; TODO: above code loads a[i], a[i+1], b[i], b[i+1] respectively... now write the rest of the logic...

        ; TODO: end of loop: jump to loop if at least 2 elements left else go to one

one:    ; TODO: if zero elements left, go to done, else run 1 iteration on that 1 element!

done:
        ; ---- end: DO NOT EDIT ----
        syscall 0                ; stop the simulator

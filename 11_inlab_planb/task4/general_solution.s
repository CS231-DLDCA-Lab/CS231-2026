; general_solution.s -- c[i] = a[i] + b[i] for any N >= 0, as fast as we can.
;
; Three loops run one after the other:
;   loop4  4 elements per pass while at least 4 are left,
;   loop2  2 elements per pass while at least 2 are left (runs at most once),
;   loop1  1 element per pass while at least 1 is left (runs at most once).
;
; Each loop has two tests, both `slti` + a branch: one before the loop (skip
; it if too few elements are left) and one at the bottom (go around again).
; r20 holds the result of the test.
;
; Every value is produced at least two instructions before it is used, and
; each `slti` sits well above the branch that reads it, so nothing waits,
; with or without forwarding. Only the three tests before the loops wait
; 1 cycle without forwarding.

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

        slti  r20, r4, 4
        bne   r20, r0, two

loop4:
        ld    r5, 0(r1)
        ld    r6, 0(r2)
        ld    r8, 8(r1)
        ld    r9, 8(r2)
        ld    r11, 16(r1)
        ld    r12, 16(r2)
        ld    r14, 24(r1)
        ld    r15, 24(r2)

        daddi r4, r4, -4
        dadd  r7, r5, r6
        dadd  r10, r8, r9
        dadd  r13, r11, r12
        dadd  r16, r14, r15

        slti  r20, r4, 4
        daddi r1, r1, 32
        sd    r7, 0(r3)
        sd    r10, 8(r3)
        sd    r13, 16(r3)
        sd    r16, 24(r3)
        daddi r2, r2, 32
        daddi r3, r3, 32

        beq   r20, r0, loop4

two:
        slti  r20, r4, 2
        ld    r5, 0(r1)      ; branch delay slot :P
        bne   r20, r0, one

        ld    r6, 0(r2)
        ld    r8, 8(r1)
        ld    r9, 8(r2)

        daddi r4, r4, -2
        dadd  r7, r5, r6
        dadd  r10, r8, r9

        daddi r1, r1, 16
        sd    r7, 0(r3)
        sd    r10, 8(r3)
        daddi r2, r2, 16
        daddi r3, r3, 16

one:
        slti  r20, r4, 1
        ld    r5, 0(r1)      ; branch delay slot :P
        bne   r20, r0, done

        ld    r6, 0(r2)
        dadd  r7, r5, r6
        sd    r7, 0(r3)

done:
        syscall 0
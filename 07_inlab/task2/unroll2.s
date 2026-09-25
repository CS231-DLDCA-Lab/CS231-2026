; unroll2.s -- unroll the loop of loop.s by 2.
;
; One iteration of your loop handles 2 elements, so the branch, the counter
; and the pointer updates are paid once per 2 elements. c must end up as
; a[i] + b[i]. In the tests N is a multiple of 2.
;
; Hints:
;   - Element j of an iteration is at offset 8*j: 0(r1), 8(r1), ...
;   - Give each element its own registers.
;   - Advance each pointer by 8*2 once per iteration, and subtract 2 from r4.
;
; As given, the program stops without writing c.
; The data below is the test with N = 8; `make task2-tests` writes the others.

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

loop:   ; TODO: unrolled loop body, ending with the branch back to loop

        syscall 0                ; stop the simulator

; sum.s -- sum of an array, unrolled by 4.                        (TODO)
;
; Compute s = a[0] + a[1] + ... + a[N-1] with a loop that handles 4
; elements per iteration. N is a multiple of 4, N >= 4.
; When your code reaches the end block, r5 must hold the total.

        .data
n:      .word 8                  ; N, the number of elements
s:      .space 8                 ; the sum, written by the program
a:      .word 11, 48, 85, 122, 159, 196, 233, 270
guard:  .word 1000000, 1000000   ; not part of a: a loop that reads past the end adds these

        .text
        ; ---- setup: DO NOT EDIT ----
        ld    r4, n(r0)          ; r4 = N, the number of elements left
        daddi r1, r0, a          ; r1 -> a[0]
        dadd  r5, r0, r0         ; r5 = 0, the total
        ; ---- end of setup ----

        ; TODO
        ; ensure your final answer sits in r5 at the end of the code block

        ; ---- end: DO NOT EDIT ----
        sd    r5, s(r0)          ; s = total
        syscall 0                ; stop the simulator

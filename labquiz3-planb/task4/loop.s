; loop.s -- c[i] = 5*a[i] + b[i] for i = 0..N-1, one element per iteration.
; PROVIDED, DO NOT EDIT. This is the baseline for both parts of Q4.
;
; Each element is a 64-bit word (8 bytes). r1, r2, r3 point to the current
; element of a, b and c, and r4 counts the elements that are left.
; 5*a[i] is computed as (a[i] << 2) + a[i]. N >= 1.
;
; The data section is the test with N = 8; expected c: 62, 300, 538, 776,
; 1014, 1252, 1490, 1728. `make task4` replaces it with other test sizes.

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

loop:   ld    r5, 0(r1)          ; r5 = a[i]
        ld    r6, 0(r2)          ; r6 = b[i]
        dsll  r7, r5, 2          ; r7 = 4 * a[i]
        dadd  r7, r7, r5         ; r7 = 5 * a[i]
        dadd  r7, r7, r6         ; r7 = 5 * a[i] + b[i]
        sd    r7, 0(r3)          ; c[i] = r7
        daddi r1, r1, 8          ; move each pointer to the next word
        daddi r2, r2, 8
        daddi r3, r3, 8
        daddi r4, r4, -1         ; one element done
        bne   r4, r0, loop       ; repeat while elements are left

        ; ---- end: DO NOT EDIT ----
        syscall 0                ; stop the simulator

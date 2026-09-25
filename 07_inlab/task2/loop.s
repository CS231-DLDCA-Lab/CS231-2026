; loop.s -- element-wise vector add: c[i] = a[i] + b[i] for i = 0..N-1.
;
; Each element is a 64-bit word (8 bytes). Three pointers walk through
; the arrays and r4 counts how many elements are left. The program
; assumes N >= 1.
;
; The data section is the test with N = 8; expected c: 8, 28, 48, 68, 88,
; 108, 128, 148. `make task2-tests` writes other test sizes as text that
; can be pasted over the data section.

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

loop:   ld    r5, 0(r1)          ; r5 = a[i]
        ld    r6, 0(r2)          ; r6 = b[i]
        dadd  r7, r5, r6         ; r7 = a[i] + b[i]
        sd    r7, 0(r3)          ; c[i] = r7
        daddi r1, r1, 8          ; move each pointer to the next word
        daddi r2, r2, 8
        daddi r3, r3, 8
        daddi r4, r4, -1         ; one element done
        bne   r4, r0, loop       ; repeat while elements are left

        syscall 0                ; stop the simulator

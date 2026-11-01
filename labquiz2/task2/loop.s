; loop.s -- sum of an array: s = a[0] + a[1] + ... + a[N-1], one element per iteration.
;
; Each element is a 64-bit word (8 bytes). r1 walks through the array, r4
; counts the elements that are left, and r5 holds the running total.
;

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

loop:   ld    r6, 0(r1)          ; r6 = a[i]
        dadd  r5, r5, r6         ; total += a[i]
        daddi r1, r1, 8          ; move the pointer to the next word
        daddi r4, r4, -1         ; one element done
        bne   r4, r0, loop       ; repeat while elements are left

        ; ---- end: DO NOT EDIT ----
        sd    r5, s(r0)          ; s = total
        syscall 0                ; stop the simulator

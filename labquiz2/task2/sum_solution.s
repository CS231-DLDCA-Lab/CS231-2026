; sum_solution.s -- sum of an array, unrolled by 4 with four accumulators.
;
; One iteration loads a[i] .. a[i+3] and adds each into its own total
; (r5, r10, r11, r12), so no add waits for the add before it. After the
; loop the four totals are added into r5. N is a multiple of 4, N >= 4.
;
; Cycles for N = 4096, forwarding off:
;   this file                                    11285  (all three budgets)
;   alternate A: counter in r4, moved up         12306  (14400 and 12352)
;   alternate B: Steps 2 and 3 only              14354  (14400 only)
; This version has no counter: it stops when r1 reaches the end of a, so
; one iteration is 10 instructions + 1 branch bubble with no stalls.
; With one taken branch per 4 elements and no delay slot, that is the minimum.
;
; The data section is the test with N = 8; expected s = 1124.
; `make task2` replaces it with the other test sizes.

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

        dadd  r10, r0, r0        ; three more totals, all 0
        dadd  r11, r0, r0
        dsll  r2, r4, 3          ; r2 = 8N, the size of a in bytes
        dadd  r12, r0, r0
        dadd  r2, r2, r1         ; r2 -> just past a[N-1]

loop:   ld    r6, 0(r1)          ; a[i]
        ld    r7, 8(r1)          ; a[i+1]
        ld    r8, 16(r1)         ; a[i+2]
        ld    r9, 24(r1)         ; a[i+3]
        daddi r1, r1, 32         ; pointer early: bne reads r1 four instructions later
        dadd  r5, r5, r6         ; each element goes into its own total,
        dadd  r10, r10, r7       ; so these four adds do not depend on
        dadd  r11, r11, r8       ; each other
        dadd  r12, r12, r9
        bne   r1, r2, loop       ; repeat until r1 reaches the end of a

        dadd  r5, r5, r10        ; total = r5 + r10 + r11 + r12
        dadd  r11, r11, r12
        dadd  r5, r5, r11

        ; ---- end: DO NOT EDIT ----
        sd    r5, s(r0)          ; s = total
        syscall 0                ; stop the simulator

; Alternate A: keep the counter in r4, but update it early so that bne does
; not wait for it. 11 instructions + 1 bubble per iteration: 12306 cycles.
;
;       dadd  r10, r0, r0
;       dadd  r11, r0, r0
;       dadd  r12, r0, r0
; loop: ld    r6, 0(r1)
;       ld    r7, 8(r1)
;       ld    r8, 16(r1)
;       ld    r9, 24(r1)
;       daddi r4, r4, -4         ; counter early: bne reads r4 six instructions later
;       daddi r1, r1, 32
;       dadd  r5, r5, r6
;       dadd  r10, r10, r7
;       dadd  r11, r11, r8
;       dadd  r12, r12, r9
;       bne   r4, r0, loop
;       dadd  r5, r5, r10
;       dadd  r11, r11, r12
;       dadd  r5, r5, r11
;
; Alternate B: Steps 2 and 3 only, no reordering. The bne waits 2 cycles for
; the daddi right before it: 14354 cycles.
;
;       dadd  r10, r0, r0
;       dadd  r11, r0, r0
;       dadd  r12, r0, r0
; loop: ld    r6, 0(r1)
;       ld    r7, 8(r1)
;       ld    r8, 16(r1)
;       ld    r9, 24(r1)
;       dadd  r5, r5, r6
;       dadd  r10, r10, r7
;       dadd  r11, r11, r8
;       dadd  r12, r12, r9
;       daddi r1, r1, 32
;       daddi r4, r4, -4
;       bne   r4, r0, loop
;       dadd  r5, r5, r10
;       dadd  r11, r11, r12
;       dadd  r5, r5, r11

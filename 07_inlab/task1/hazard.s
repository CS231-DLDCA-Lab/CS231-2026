; hazard.s
; Computes res = 2*(a + b) - a, then branches over an error path.
;
; Draw the pipeline twice:
;   1. without forwarding
;   2. with forwarding
;
; Look for:
;   - RAW hazards and forwarding paths
;   - the load-use hazard
;   - the taken branch and the instruction fetched behind it

        .data
a:      .word 5
b:      .word 7
res:    .word 0

        .text
        ld    r1, a(r0)         ; r1 = a
        ld    r2, b(r0)         ; r2 = b
        dadd  r3, r1, r2       ; r3 = a + b
        dadd  r4, r3, r3       ; r4 = 2*(a + b)
        dsub  r5, r4, r1       ; r5 = 2*(a + b) - a
        sd    r5, res(r0)       ; store result

        daddi r6, r0, 1        ; condition = true
        bne   r6, r0, done     ; taken: skip error path
        daddi r5, r0, -1       ; should never execute
        sd    r5, res(r0)       ; should never execute

done:   syscall 0

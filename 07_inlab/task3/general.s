; general.s -- c[i] = a[i] + b[i] for ANY N >= 0.
;
; Three loops run one after the other, each with its own compare and jump:
;   loop4  4 elements per iteration while at least 4 are left
;   loop2  2 elements per iteration while at least 2 are left
;   loop1  1 element per iteration while at least 1 is left
;
; Goal: correct for every N, and as fast as possible (remove RAW and other
; stalls).
;
; Hints:
;   - r4 is the number of elements left. Each loop needs a test to enter it
;     and a test to repeat it.
;   - `slti rd, rs, imm` sets rd to 1 if rs < imm; then `bne`/`beq` on rd.
;   - A branch reads its register in ID: compute its condition early.
;   - Tests: N = 8, 6, 9, 1024, 2047, 4098.
;
; As given, the program stops without writing c.
; The data below is the test with N = 8; `make task3-tests` writes the others.

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

        ; TODO: loop4 -- 4 elements per iteration while at least 4 are left
        ; TODO: loop2 -- 2 elements per iteration while at least 2 are left
        ; TODO: loop1 -- 1 element per iteration while at least 1 is left

done:   syscall 0                ; stop the simulator

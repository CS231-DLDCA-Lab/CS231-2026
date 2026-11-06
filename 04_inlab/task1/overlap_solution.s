section .data
; Each rect is 4 consecutive qwords: x1, y1, x2, y2
; Treat each rect's x-extent and y-extent as OPEN intervals (x1, x2) and
; (y1, y2) -- a rect does not include its own boundary. Two rects overlap
; iff both their x-intervals and y-intervals intersect as open intervals:
;
;   a.x1 < b.x2  AND  a.x2 > b.x1  AND  a.y1 < b.y2  AND  a.y2 > b.y1
;
; (Rects that only touch along an edge, with no interior overlap, do NOT
; count as overlapping)
    rect_a:
        .x1: dq 0
        .y1: dq 0
        .x2: dq 10
        .y2: dq 10

    rect_b:
        .x1: dq 5
        .y1: dq 5
        .x2: dq 15
        .y2: dq 15
 
    ;; The rectangles overlap by default
 
section .text
    global _start


_start:
; put 1 in rdi if rectangles overlap, 0 otherwise
    xor edi, edi

    mov rax, [rect_a.x1]
    cmp rax, [rect_b.x2]
    jge .no

    mov rax, [rect_b.x1]
    cmp rax, [rect_a.x2]
    jge .no

    mov rax, [rect_a.y1]
    cmp rax, [rect_b.y2]
    jge .no

    mov rax, [rect_b.y1]
    cmp rax, [rect_a.y2]
    jge .no

    inc edi
.no:
    mov rax, 60
    syscall


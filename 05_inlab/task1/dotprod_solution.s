section .data
    vec1:
        dq 1.5, 2.5, -1.0, 3.2
    .end:

    vec2:
        dq 2.0, 3.0, 4.0, 1.5
    .end:

    vecsize equ (vec1.end - vec1)/8

    ;; dot(vec1, vec2) is 11.3 by default

%if (vec1.end-vec1) != (vec2.end-vec2)
    %error "Both vectors should have same size"
%endif

section .text
    global _start

_start:
;   Find the dot product of vec1 and vec2 (as doubles), truncate it toward
;   zero, and put the result in `rdi`
    xorps xmm0, xmm0
    xor ecx, ecx
.for:
    movsd xmm1, qword [vec1+8*rcx]
    mulsd xmm1, qword [vec2+8*rcx]
    addsd xmm0, xmm1
    inc rcx
    cmp rcx, vecsize
    jl .for

    cvttsd2si rdi, xmm0

    mov rax, 60
    syscall

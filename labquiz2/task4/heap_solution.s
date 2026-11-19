    global push_heap
    global pop_heap

; struct heap, as laid out by the C++ class in main.cpp
HEAP_DATA   equ 0       ; int64_t* data
HEAP_SIZE   equ 8       ; size_t   size
HEAP_CAP    equ 16      ; size_t   capacity (owned by C++, never changed here)

section .text

; push_heap(heap* h{rdi}, int64_t val{rsi})
;
; C++ makes sure size < capacity, so data[size] is free.
; Sift-up: start with a hole at i = size and move parents down into the hole
; while they are smaller than val, then put val in the hole.
push_heap:
    mov     r8, [rdi + HEAP_DATA]   ; r8  = data
    mov     rcx, [rdi + HEAP_SIZE]  ; rcx = i = size (the new slot)
    mov     rax, rcx
    inc     rax
    mov     [rdi + HEAP_SIZE], rax  ; size = size + 1

.up:
    test    rcx, rcx
    jz      .place                  ; i = 0: the hole is at the root
    mov     rdx, rcx
    dec     rdx
    shr     rdx, 1                  ; rdx = p = (i - 1) / 2, the parent of i
    mov     r9, [r8 + rdx*8]        ; r9 = data[p]  (8 bytes per element)
    cmp     r9, rsi
    jge     .place                  ; jge = (int64_t)data[p] >= val: heap order holds, stop
    mov     [r8 + rcx*8], r9        ; data[i] = data[p]: parent moves down
    mov     rcx, rdx                ; i = p
    jmp     .up

.place:
    mov     [r8 + rcx*8], rsi       ; data[i] = val
    ret

; pop_heap(heap* h{rdi}) -> int64_t{rax}
;
; C++ makes sure size > 0.
; The root (the largest value) is returned and also stored at data[n], where
; n = size - 1 is the new size. The old last element is then sifted down from
; the root inside data[0 .. n-1].
pop_heap:
    mov     r8, [rdi + HEAP_DATA]   ; r8  = data
    mov     rcx, [rdi + HEAP_SIZE]
    dec     rcx                     ; rcx = n = size - 1
    mov     [rdi + HEAP_SIZE], rcx  ; size = n
    mov     rax, [r8]               ; rax = top = data[0], the return value
    mov     rsi, [r8 + rcx*8]       ; rsi = last = data[n]
    mov     [r8 + rcx*8], rax       ; data[n] = top
    xor     edx, edx                ; rdx = i = 0, the hole

.down:
    mov     r9, rdx
    shl     r9, 1
    inc     r9                      ; r9 = c = 2i + 1, the left child
    cmp     r9, rcx
    jae     .place                  ; c >= n: i has no children
    mov     r10, r9
    inc     r10                     ; r10 = c + 1, the right child
    cmp     r10, rcx
    jae     .have_child             ; no right child
    mov     r11, [r8 + r10*8]       ; r11 = data[c + 1]
    cmp     r11, [r8 + r9*8]
    jle     .have_child             ; right <= left: keep the left child (ties go left)
    mov     r9, r10                 ; c = c + 1
.have_child:
    mov     r11, [r8 + r9*8]        ; r11 = data[c], the larger child
    cmp     r11, rsi
    jle     .place                  ; jle = (int64_t)data[c] <= last: heap order holds, stop
    mov     [r8 + rdx*8], r11       ; data[i] = data[c]: child moves up
    mov     rdx, r9                 ; i = c
    jmp     .down

.place:
    mov     [r8 + rdx*8], rsi       ; data[i] = last
    ret                             ; rax = top

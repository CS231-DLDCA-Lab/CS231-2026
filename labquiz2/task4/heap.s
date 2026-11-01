    global push_heap
    global pop_heap

; struct heap, as laid out by the C++ class in main.cpp
HEAP_DATA   equ 0       ; int64_t* data
HEAP_SIZE   equ 8       ; size_t   size
HEAP_CAP    equ 16      ; size_t   capacity (owned by C++, never changed here)

; Elements are int64_t, 8 bytes each: data[k] is at address data + 8*k.
; Compare elements as signed numbers.

section .text

; push_heap(heap* h{rdi}, int64_t val{rsi})
;
; C++ makes sure size < capacity, so data[size] is free.
; Outline (sift-up, see the pseudocode in the PDF):
;   i = size; size = size + 1
;   while i > 0 and data[(i - 1) / 2] < val:
;       data[i] = data[(i - 1) / 2]; i = (i - 1) / 2
;   data[i] = val
push_heap:
    ; TODO

    ret

; pop_heap(heap* h{rdi}) -> int64_t{rax}
;
; C++ makes sure size > 0.
; Outline (sift-down, see the pseudocode in the PDF):
;   n = size - 1; size = n
;   top = data[0]; last = data[n]; data[n] = top
;   sift last down from i = 0 inside data[0 .. n-1]
;   return top
pop_heap:
    ; TODO

    ret

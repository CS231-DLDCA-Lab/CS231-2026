section .bss
    buf: resb 4096

section .text
    global _start

_start:
;   argv[1] (at [rsp+16]) through to argv[argc-1] are filenames. 
;   Open it read-only, then repeatedly read chunks and write it straight
;   to stdout until read() returns 0 (EOF), then close the file and exit 0.
;   Make your own functions for convenience!

    mov rax, 60
    syscall

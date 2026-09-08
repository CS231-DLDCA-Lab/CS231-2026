section .rodata
    error_msg: db "There should be 3 command line arguments!",10
    .end: db 0 ; null terminator for the TA's mental peace
    error_msg_len equ (error_msg.end-error_msg)

section .text
    global _start

; my_strlen(const char* str{rdi}) -> rax (not counting the null terminator)
my_strlen:

    ret

; my_atoi(const char* str{rdi}) -> rax (handles an optional leading '-')
my_atoi:

    ret

; gcd(int64_t a{rdi}, int64_t b{rsi}) -> rax
gcd:

    ret

_start:
;   check argc at [rsp] if it is 3, if not print error_msg and exit.
;   argv[1] is at [rsp+16], argv[2] is at [rsp+24] (argc is at [rsp]).
;   Print argv[1] as-is (using my_strlen + a direct write syscall), then
;   exit with gcd(atoi(argv[1]), atoi(argv[2])).

    mov rax, 60
    syscall

extern printf
extern exit
extern localtime_r

section .data
    DDMMYYYY_FMT: db "%02d/%02d/%04d ", 0
    hhmmss_FMT: db "%02d:%02d:%02d", 10, 0

section .bss
    epoch_secs: resq 1

    tm_buf:
        .tm_sec: resd 1
        .tm_min: resd 1
        .tm_hour: resd 1
        .tm_mday: resd 1
        .tm_mon: resd 1
        .tm_year: resd 1
        .tm_wday: resd 1
        .tm_yday: resd 1
        .tm_isdst: resd 1
        resd 1
        .tm_gmtoff: resq 1
        .tm_zone: resq 1

section .text
    global _start

_start:
    and rsp, -16
;   Get the current time via the time syscall (number 201, takes a single
;   argument -- a pointer to also store the result at, or NULL if you only
;   want it in rax). Then, convert it to a readable format using localtime_r.
    

    ; exit(0)
    xor edi, edi
    call exit
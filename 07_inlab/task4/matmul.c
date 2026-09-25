/* matmul.c: square matrix multiply C = A * B on doubles.
 *
 * Build and run: make task4 args=256   (from the 07_inlab folder; N defaults to 512)
 * Under perf:    taskset -c N perf stat ./task4.out 256   (N = a core number)
 *
 * The multiply is timed two ways:
 *   1. clock_gettime(CLOCK_MONOTONIC): wall-clock nanoseconds.
 *   2. __rdtsc(): the CPU's time stamp counter (TSC ticks, see note below).
 * It also prints the tick rate in MHz (ticks per microsecond). On one
 * machine that rate is fixed, so ns = ticks * 1000 / MHz for any region.
 * Nothing is printed inside the timed region, so I/O does not pollute it.
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <x86intrin.h> /* __rdtsc() */

/* Fixed-size storage keeps setup cost tiny; N (from argv) must be <= MAXN. */
#define MAXN 1024
static double A[MAXN][MAXN], B[MAXN][MAXN], C[MAXN][MAXN];

/* Cheap deterministic fill: no rand(), same values on every run. */
static void init(int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
            A[i][j] = (i + j) % 10;
            B[i][j] = (i - j) % 10;
            C[i][j] = 0.0;
        }
}

/* The work we want to measure: the classic triple loop. */
static void multiply(int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            for (int k = 0; k < n; k++)
                C[i][j] += A[i][k] * B[k][j];
}

/* Sum of all of C; printing it proves the multiply result is used. */
static double checksum(int n) {
    double s = 0.0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            s += C[i][j];
    return s;
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? atoi(argv[1]) : 512;
    if (n < 1 || n > MAXN) {
        fprintf(stderr, "N must be between 1 and %d\n", MAXN);
        return 1;
    }

    init(n);

    /* ---- timed region starts ---- */
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    _mm_lfence();                 /* wait for earlier instructions; see Task 6 */
    unsigned long long c0 = __rdtsc();

    multiply(n);

    _mm_lfence();
    unsigned long long c1 = __rdtsc();
    clock_gettime(CLOCK_MONOTONIC, &t1);
    /* ---- timed region ends ---- */

    long long ns = (long long)(t1.tv_sec - t0.tv_sec) * 1000000000LL
                   + (t1.tv_nsec - t0.tv_nsec);

    /* Note: TSC ticks at a fixed rate on modern CPUs, which need not equal
     * the current core clock (turbo/idle changes the core clock only). */
    unsigned long long ticks = c1 - c0;
    /* MHz and the ns computed from the ticks stay in double: no integer truncation. */
    double mhz = ticks * 1000.0 / ns;
    double tsc_ns = (double)ticks / mhz * 1000.0;
    printf("N=%d  tsc_ticks=%llu  tsc_MHz=%llu\ntsc_ns=%.0f  clock_gettime_ns=%lld\nchecksum=%.0f\n",
           n, ticks, ticks * 1000 / ns, tsc_ns, ns, checksum(n));
    return 0;
}

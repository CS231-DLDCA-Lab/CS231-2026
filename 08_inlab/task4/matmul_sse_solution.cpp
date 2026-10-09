#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <xmmintrin.h>

const int MAXN = 1024;
static float A[MAXN][MAXN], B[MAXN][MAXN], C[MAXN][MAXN];

void multiply_scalar(int n) {
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++) {
            float a = A[i][k];
            for (int j = 0; j < n; j++)
                C[i][j] += a * B[k][j];
        }
}

/* ========================= YOUR CODE BELOW ========================= */

void multiply_sse(int n) {
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++) {
            float a = A[i][k];
            __m128 a4 = _mm_set1_ps(a);
            int j = 0;
            for (; j + 4 <= n; j += 4) {
                __m128 b4 = _mm_loadu_ps(&B[k][j]);
                __m128 c4 = _mm_loadu_ps(&C[i][j]);
                c4 = _mm_add_ps(c4, _mm_mul_ps(a4, b4));
                _mm_storeu_ps(&C[i][j], c4);
            }
            for (; j < n; j++)
                C[i][j] += a * B[k][j];
        }
}

/* ========================= YOUR CODE ABOVE ========================= */

/* ===================== DO NOT EDIT BELOW THIS LINE ===================== */

void init(int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++) {
            A[i][j] = (i + j) % 10;
            B[i][j] = (i - j + MAXN) % 10;
        }
}

double checksum(int n) {
    double s = 0.0;
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            s += C[i][j];
    return s;
}

double run(const char *name, void (*multiply)(int), int n, double *sum) {
    std::memset(C, 0, sizeof C);
    auto t0 = std::chrono::steady_clock::now();
    multiply(n);
    auto t1 = std::chrono::steady_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    *sum = checksum(n);
    std::printf("%-6s: %8.1f ms   checksum=%.0f\n", name, ms, *sum);
    return ms;
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? std::atoi(argv[1]) : 512;
    std::string which = (argc > 2) ? argv[2] : "both";
    if (n < 1 || n > MAXN) {
        std::fprintf(stderr, "N must be between 1 and %d\n", MAXN);
        return 1;
    }
    init(n);

    double s1, s2;
    if (which == "scalar") {
        run("scalar", multiply_scalar, n, &s1);
    } else if (which == "sse") {
        run("sse", multiply_sse, n, &s2);
    } else {
        double t1 = run("scalar", multiply_scalar, n, &s1);
        double t2 = run("sse", multiply_sse, n, &s2);
        std::printf("%s   speedup = %.2fx\n",
                    s1 == s2 ? "checksums match" : "checksums DIFFER", t1 / t2);
    }
    return 0;
}

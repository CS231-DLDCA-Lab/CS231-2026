#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

const int MAXN = 1024;
static float A[MAXN][MAXN], B[MAXN][MAXN], C[MAXN][MAXN];

void multiply_ijk(int n) {
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            for (int k = 0; k < n; k++)
                C[i][j] += A[i][k] * B[k][j];
}

/* ========================= YOUR CODE BELOW ========================= */

void multiply_ikj(int n) {
    for (int i = 0; i < n; i++)
        for (int k = 0; k < n; k++) {
            float a = A[i][k];
            for (int j = 0; j < n; j++)
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

double run(const char *name, void (*multiply)(int), int n) {
    std::memset(C, 0, sizeof C);
    auto t0 = std::chrono::steady_clock::now();
    multiply(n);
    auto t1 = std::chrono::steady_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    double sum = checksum(n);
    std::printf("%s: %8.1f ms   checksum=%.0f\n", name, ms, sum);
    return sum;
}

int main(int argc, char **argv) {
    int n = (argc > 1) ? std::atoi(argv[1]) : 512;
    std::string which = (argc > 2) ? argv[2] : "both";
    if (n < 1 || n > MAXN) {
        std::fprintf(stderr, "N must be between 1 and %d\n", MAXN);
        return 1;
    }
    init(n);

    if (which == "ijk") {
        run("ijk", multiply_ijk, n);
    } else if (which == "ikj") {
        run("ikj", multiply_ikj, n);
    } else {
        double a = run("ijk", multiply_ijk, n);
        double b = run("ikj", multiply_ikj, n);
        std::printf("%s\n", a == b ? "checksums match" : "checksums DIFFER");
    }
    return 0;
}

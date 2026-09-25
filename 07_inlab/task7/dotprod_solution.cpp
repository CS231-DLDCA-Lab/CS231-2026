// dotprod_solution.cpp -- the fixed version of dotprod.cpp.
#include <chrono>
#include <cstdio>

constexpr int N = 100000;          // vector length
static double a[N], b[N];

double dot(const double* x, const double* y, int n) {
    double s = 0.0;
    for (int i = 0; i < n; i++) s += x[i] * y[i];
    return s;
}

int main() {
    using clock = std::chrono::steady_clock;
    constexpr int REPS = 1000;     // fix 1: repeat the measured code and divide

    for (int i = 0; i < N; i++) {
        a[i] = (i % 10) * 0.5;
        b[i] = (i % 7) * 0.25;
    }

    // fix 2: a volatile variable. Every store to it must really happen, so the
    // compiler cannot delete the dot product or merge the repeated calls.
    volatile double sink = 0.0;

    auto t0 = clock::now();
    for (int r = 0; r < REPS; r++)
        sink = dot(a, b, N);
    auto t1 = clock::now();

    // fix 3: use the result! otherwise compiler deletes it anyway
    double ns = std::chrono::duration<double, std::nano>(t1 - t0).count() / REPS;
    std::printf("dot: %.1f ns per call (result %.1f)\n", ns, (double)sink);
    return 0;
}

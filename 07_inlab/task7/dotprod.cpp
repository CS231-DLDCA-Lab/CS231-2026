// dotprod.cpp -- times a dot product of two vectors with std::chrono.
//
// Build and run: make task7      (compiled with -O2, like real code)
//
// This program is broken: the number it prints is nonsense. Find out why and
// fix it (see the problem statement). The dot product itself is correct;
// only the way it is timed is wrong.
#include <chrono>
#include <cstdio>

constexpr int N = 100000;          // vector length
static double a[N], b[N];

// Sum of a[i] * b[i]. Correct as written; do not change it.
double dot(const double* x, const double* y, int n) {
    double s = 0.0;
    for (int i = 0; i < n; i++) s += x[i] * y[i];
    return s;
}

int main() {
    using clock = std::chrono::steady_clock;

    for (int i = 0; i < N; i++) {  // fill the vectors with fixed values
        a[i] = (i % 10) * 0.5;
        b[i] = (i % 7) * 0.25;
    }

    double result;

    auto t0 = clock::now();
    result = dot(a, b, N);
    auto t1 = clock::now();

    double ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
    std::printf("dot: %.1f ns per call\n", ns);
    return 0;
}

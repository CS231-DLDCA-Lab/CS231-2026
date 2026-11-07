#include <chrono>
#include <cmath>
#include <cstdio>

const int N = 2048;
const int DEG = 7;
const int RUNS = 5;
const double TARGET = 1.5;

static float in[N][N];
static float out_ref[N][N];
static float out[N][N];

const float coef[DEG + 1] = {
    1.0f, -0.5f, 0.25f, -0.125f, 0.0625f, -0.03125f, 0.015625f, -0.0078125f
};

/* ===================== DO NOT EDIT BELOW THIS LINE ===================== */

void poly_slow() {
    for (int j = 0; j < N; j++)
        for (int i = 0; i < N; i++) {
            float x = in[i][j];
            float r = coef[DEG];
            for (int d = DEG - 1; d >= 0; d--)
                r = r * x + coef[d];
            out_ref[i][j] = r;
        }
}

/* ===================== DO NOT EDIT ABOVE THIS LINE ===================== */

/* ========================= YOUR CODE BELOW ========================= */

void poly_fast() {
    // Same work as poly_slow, but the inner loop walks along a row (j),
    // so consecutive reads of in[i][j] are neighbours in the same cache line.
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float x = in[i][j];
            float r = coef[DEG];
            for (int d = DEG - 1; d >= 0; d--)
                r = r * x + coef[d];
            out[i][j] = r;
        }
}

/* ========================= YOUR CODE ABOVE ========================= */

/* ===================== DO NOT EDIT BELOW THIS LINE ===================== */

void init() {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            in[i][j] = ((i * 31 + j * 17) % 2001 - 1000) / 1000.0f;
}

double best_of(void (*f)()) {
    double best = 1e30;
    for (int r = 0; r < RUNS; r++) {
        auto t0 = std::chrono::steady_clock::now();
        f();
        auto t1 = std::chrono::steady_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        if (ms < best)
            best = ms;
    }
    return best;
}

int main() {
    init();

    double t_fast = best_of(poly_fast);
    double t_slow = best_of(poly_slow);

    int wrong = 0;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            if (std::fabs(out[i][j] - out_ref[i][j]) > 1e-5f)
                wrong++;

    double speedup = t_slow / t_fast;
    bool pass = (wrong == 0 && speedup >= TARGET);
    std::printf("slow: %7.2f ms\nfast: %7.2f ms\nspeedup: %.2fx\n", t_slow, t_fast, speedup);
    std::printf("wrong elements: %d\n", wrong);
    std::printf("target (>= %.1fx): %s\n", TARGET, pass ? "PASS" : "FAIL");
    return 0;
}

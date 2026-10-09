#include <algorithm>
#include <chrono>
#include <cstdio>
#include <random>
#include <string>

const int N = 32768;
const int REPS = 2000;
const int T = 128;

static int a[N];

long sum_branchy() {
    long s = 0;
    for (int r = 0; r < REPS; r++)
        for (int j = 0; j < N; j++) {
            if (a[j] >= T)
                s += a[j];
            else
                s -= a[j];
        }
    return s;
}

/* ========================= YOUR CODE BELOW ========================= */

long sum_branchless() {
    long s = 0;
    for (int r = 0; r < REPS; r++)
        for (int j = 0; j < N; j++) {
            int big = (a[j] >= T);
            int sign = 2 * big - 1;
            s += sign * a[j];
        }
    return s;
}

/* Alternate solution: mask trick, no multiply.
long sum_branchless() {
    long s = 0;
    for (int r = 0; r < REPS; r++)
        for (int j = 0; j < N; j++) {
            int mask = -(a[j] < T);
            s += (a[j] ^ mask) - mask;
        }
    return s;
}
*/

/* ========================= YOUR CODE ABOVE ========================= */

/* ===================== DO NOT EDIT BELOW THIS LINE ===================== */

void fill_random() {
    std::mt19937 rng(42);
    for (int j = 0; j < N; j++)
        a[j] = rng() % 256;
}

long run(const char *name, long (*sum)()) {
    auto t0 = std::chrono::steady_clock::now();
    long s = sum();
    auto t1 = std::chrono::steady_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    std::printf("%-10s: %8.1f ms   sum=%ld\n", name, ms, s);
    return s;
}

int main(int argc, char **argv) {
    std::string which = (argc > 1) ? argv[1] : "all";
    bool all = (which == "all");
    long r1 = 0, r2 = 0, r3 = 0;

    if (all || which == "random") {
        fill_random();
        r1 = run("random", sum_branchy);
    }
    if (all || which == "branchless") {
        fill_random();
        r3 = run("branchless", sum_branchless);
    }
    if (all || which == "sorted") {
        fill_random();
        std::sort(a, a + N);
        r2 = run("sorted", sum_branchy);
    }
    if (all)
        std::printf("%s\n", (r1 == r2 && r1 == r3) ? "sums match" : "sums DIFFER");
    return 0;
}

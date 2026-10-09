#include <algorithm>
#include <chrono>
#include <cstdio>
#include <numeric>
#include <random>
#include <vector>

const long STEP = 16;
const long READS = 1L << 23;

int main() {
    for (long kb = 4; kb <= 64 * 1024; kb *= 2) {
        long n = kb * 1024 / sizeof(int);
        long lines = n / STEP;

        std::vector<long> order(lines);
        std::iota(order.begin(), order.end(), 0);
        std::shuffle(order.begin(), order.end(), std::mt19937(42));

        std::vector<int> next(n);
        for (long k = 0; k < lines; k++)
            next[order[k] * STEP] = order[(k + 1) % lines] * STEP;

        /* ========================= YOUR CODE BELOW ========================= */


        // Warmup
        long i = 0;
        for (long k = 0; k < lines; k++)
            i = next[i];

        auto t0 = std::chrono::steady_clock::now();
        for (long r = 0; r < READS; r++)
            i = next[i];
        auto t1 = std::chrono::steady_clock::now();

        double ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
        std::printf("%ld %.2f\n", kb, ns / READS);

        /* ========================= YOUR CODE ABOVE ========================= */
    }
}

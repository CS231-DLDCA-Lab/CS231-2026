// chrono_demo.cpp: why tiny regions must be repeated before you time them.
//
// Build and run: make task5      (from the 07_inlab folder)
// -O0 on purpose: the compiler keeps the add and the loop as written.
// The volatile sink makes the result observable, so even at -O2 the
// add cannot be deleted.
#include <chrono>
#include <cstdio>

int main() {
    using clock = std::chrono::steady_clock;
    volatile long sink = 0;   // every write to it must really happen
    const long reps = 1000000;

    // 1) Time ONE add. The two clock reads cost about 20 ns on the
    //    author's machine, far more than one add, so this mostly measures the timer.
    clock::now();             // warm-up read: the very first call is slower (first-call setup)
    auto a0 = clock::now();
    sink = sink + 1;
    auto a1 = clock::now();
    double one_ns = std::chrono::duration<double, std::nano>(a1 - a0).count();

    // 2) Time 1,000,000 adds, then divide. The timer cost is spread over
    //    all repetitions, so the per-iteration figure is meaningful.
    auto b0 = clock::now();
    for (long i = 0; i < reps; i++)
        sink = sink + 1;
    auto b1 = clock::now();
    double many_ns = std::chrono::duration<double, std::nano>(b1 - b0).count() / reps;

    std::printf("single add  : %.2f ns (timer overhead dominates)\n", one_ns);
    std::printf("repeated add: %.2f ns per iteration (over %ld reps)\n", many_ns, reps);
    std::printf("sink=%ld\n", (long)sink);
    return 0;
}

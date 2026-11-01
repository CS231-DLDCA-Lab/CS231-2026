#include <immintrin.h>
#include "kernels.h"

// P   : D x M, row-major. Coordinate d of point j is P[d * M + j].
// out : M x M, row-major, all 0 when your function is called.
// Compute out[i * M + j] = sum over d of (P[d * M + i] - P[d * M + j])^2.
// M is a multiple of 8.

// Part 1. Same result as dist_base (base.cpp), with the three loops in the
// order that runs fastest. Start from a copy of dist_base. For each order, ask
// which array the innermost loop walks through and with what stride.
// Measure with: make task3 args="base order"
void dist_order(const float* P, int M, int D, float* out) {
    // TODO
}

// Part 2. Your loop order from Part 1, with AVX intrinsics (8 floats per
// __m256) on the innermost loop. See the intrinsics table in the PDF.
// Measure with: make task3 args="order simd"
void dist_simd(const float* P, int M, int D, float* out) {
    // TODO
}

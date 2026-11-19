#include <immintrin.h>
#include "kernels.h"

// Part 1. Loop order i, d, j.
//
// The innermost loop runs over j, so it reads P[d * M + j] and updates
// out[i * M + j] at consecutive addresses: every 64-byte cache line brought in
// is used for 16 floats. P[d * M + i] does not change inside it, so it is
// loaded once per (i, d). Row i of out is M floats (16 KiB for M = 4096); it
// is updated D times in a row and stays in the L1 cache between updates.
//
// In the base order i, j, d the innermost loop runs over d, so it reads
// P[d * M + j] with a stride of M floats: a new cache line on every step.
// Each step also adds to the same s, so every addition waits for the one
// before it. Here the additions for different j are independent.
void dist_order(const float* P, int M, int D, float* out) {
    for (int i = 0; i < M; i++)
        for (int d = 0; d < D; d++) {
            const float pi = P[d * M + i];          // coordinate d of point i
            const float* row = &P[d * M];            // coordinate d of every point
            float* o = &out[(size_t)i * M];          // row i of out
            for (int j = 0; j < M; j++) {
                float t = pi - row[j];
                o[j] += t * t;
            }
        }
}

// Part 2. The same loop order, 8 values of j at a time.
//
// For fixed i and d, the 8 outputs out[i][j .. j+7] need the same pi and 8
// consecutive coordinates row[j .. j+7], so one AVX register holds each.
// M is a multiple of 8, so no j is left over.
void dist_simd(const float* P, int M, int D, float* out) {
    for (int i = 0; i < M; i++)
        for (int d = 0; d < D; d++) {
            const __m256 pi = _mm256_set1_ps(P[d * M + i]);  // pi in all 8 lanes
            const float* row = &P[d * M];
            float* o = &out[(size_t)i * M];
            for (int j = 0; j < M; j += 8) {
                __m256 t = _mm256_sub_ps(pi, _mm256_loadu_ps(&row[j]));  // 8 differences
                __m256 acc = _mm256_loadu_ps(&o[j]);                     // out[i][j .. j+7]
                acc = _mm256_add_ps(acc, _mm256_mul_ps(t, t));
                _mm256_storeu_ps(&o[j], acc);
            }
        }
}

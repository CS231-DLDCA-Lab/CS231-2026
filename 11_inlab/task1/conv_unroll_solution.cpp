// conv_unroll.cpp  STAGE 3: unrolling for independent work.
//
// Stage 2 loads and stores the output row on every kernel tap. Here we swap the loops
// back: for a block of 16 output columns, keep the partial sums in 4 vector accumulators
// (registers) while the kernel loops run, and store them once at the end. The 4 add
// chains are independent, so several adds are in flight at once and their latency is
// hidden.
//
// Register pressure: 4 accumulators plus the loaded input and weight fit comfortably in
// the 16 SSE registers. Using many more accumulators would spill them to memory and lose
// the benefit, so a small unroll factor is enough.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  const int p = K / 2;
  const int in_stride = W + 2 * p;

  for (int oy = 0; oy < H; ++oy) {
    float* o = out + oy * W;
    int ox = 0;
    for (; ox + 16 <= W; ox += 16) {
      __m128 a0 = _mm_setzero_ps(), a1 = _mm_setzero_ps();
      __m128 a2 = _mm_setzero_ps(), a3 = _mm_setzero_ps();
      for (int ky = 0; ky < K; ++ky) {
        const float* ir = in + (oy + ky) * in_stride + ox;
        for (int kx = 0; kx < K; ++kx) {
          __m128 k = _mm_set1_ps(ker[ky * K + kx]);
          a0 = _mm_add_ps(a0, _mm_mul_ps(_mm_loadu_ps(ir + kx), k));
          a1 = _mm_add_ps(a1, _mm_mul_ps(_mm_loadu_ps(ir + kx + 4), k));
          a2 = _mm_add_ps(a2, _mm_mul_ps(_mm_loadu_ps(ir + kx + 8), k));
          a3 = _mm_add_ps(a3, _mm_mul_ps(_mm_loadu_ps(ir + kx + 12), k));
        }
      }
      _mm_storeu_ps(o + ox, a0);      _mm_storeu_ps(o + ox + 4, a1);
      _mm_storeu_ps(o + ox + 8, a2);  _mm_storeu_ps(o + ox + 12, a3);
    }
    // tail: the last few groups of 4 columns (W is a multiple of 4)
    for (; ox + 4 <= W; ox += 4) {
      __m128 acc = _mm_setzero_ps();
      for (int ky = 0; ky < K; ++ky) {
        const float* ir = in + (oy + ky) * in_stride + ox;
        for (int kx = 0; kx < K; ++kx) {
          __m128 k = _mm_set1_ps(ker[ky * K + kx]);
          acc = _mm_add_ps(acc, _mm_mul_ps(_mm_loadu_ps(ir + kx), k));
        }
      }
      _mm_storeu_ps(o + ox, acc);
    }
  }
}

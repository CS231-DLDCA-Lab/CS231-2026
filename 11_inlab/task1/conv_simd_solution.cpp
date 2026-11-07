// conv_simd.cpp  STAGE 2: SIMD.
//
// The inner ox loop of Stage 1 does the same operation on consecutive floats, which is
// what an SSE register holds: 4 floats side by side. One _mm_loadu_ps / _mm_mul_ps /
// _mm_add_ps / _mm_storeu_ps now handles 4 columns, so the inner loop runs a quarter
// of the iterations.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  const int p = K / 2;
  const int in_stride = W + 2 * p;

  for (int oy = 0; oy < H; ++oy) {
    float* o = out + oy * W;
    for (int ox = 0; ox < W; ox += 4)
      _mm_storeu_ps(o + ox, _mm_setzero_ps());
    for (int ky = 0; ky < K; ++ky) {
      for (int kx = 0; kx < K; ++kx) {
        __m128 k = _mm_set1_ps(ker[ky * K + kx]);     // the weight in all 4 lanes
        const float* ir = in + (oy + ky) * in_stride + kx;
        for (int ox = 0; ox < W; ox += 4) {
          __m128 prod = _mm_mul_ps(_mm_loadu_ps(ir + ox), k);
          _mm_storeu_ps(o + ox, _mm_add_ps(_mm_loadu_ps(o + ox), prod));
        }
      }
    }
  }
}

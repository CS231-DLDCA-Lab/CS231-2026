// conv_simd.cpp  STAGE 2: SIMD.  (TODO)
//
// The 4 running sums from Stage 1 fit in one 128-bit SSE register (4 floats). Replace
// the 4 scalar sums with one __m128 accumulator and do all 4 columns per instruction.
// Useful intrinsics: _mm_setzero_ps, _mm_set1_ps (weight into all 4 lanes),
// _mm_loadu_ps, _mm_mul_ps, _mm_add_ps, _mm_storeu_ps.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

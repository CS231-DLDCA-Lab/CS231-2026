// conv_simd.cpp  STAGE 2: SIMD.  (TODO)
//
// The inner ox loop of Stage 1 works on consecutive floats, which is what one 128-bit
// SSE register holds (4 floats). Process 4 columns per iteration: load 4 input values
// and 4 output values, multiply the inputs by the weight, add, store 4 outputs.
// Useful intrinsics: _mm_setzero_ps, _mm_set1_ps (weight into all 4 lanes),
// _mm_loadu_ps, _mm_mul_ps, _mm_add_ps, _mm_storeu_ps.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

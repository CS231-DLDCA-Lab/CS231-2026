// conv_reorder.cpp  STAGE 1: a better loop order.
//
// Loop interchange: put the two kernel loops outside and the loop over the columns
// inside. For one kernel weight, sweep the whole output row: o[ox] += ir[ox] * k.
// The weight is loaded once per row instead of once per pixel, the reads of in[] and
// o[] are consecutive, and the updates of different ox are independent of each other.

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  const int p = K / 2;
  const int in_stride = W + 2 * p;

  for (int oy = 0; oy < H; ++oy) {
    float* o = out + oy * W;
    for (int ox = 0; ox < W; ++ox)
      o[ox] = 0.0f;
    for (int ky = 0; ky < K; ++ky) {
      for (int kx = 0; kx < K; ++kx) {
        const float k = ker[ky * K + kx];
        const float* ir = in + (oy + ky) * in_stride + kx;
        for (int ox = 0; ox < W; ++ox)
          o[ox] += ir[ox] * k;
      }
    }
  }
}

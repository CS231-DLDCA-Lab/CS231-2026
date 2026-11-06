// conv_naive.cpp  the straightforward version. PROVIDED, do not edit.
//
// For each output pixel it sweeps the whole K x K kernel and accumulates into one
// variable. Every `acc +=` waits for the previous one (a dependency chain), and the
// kernel weights are re-read for every pixel.

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  const int p = K / 2;
  const int in_stride = W + 2 * p;

  for (int oy = 0; oy < H; ++oy) {
    for (int ox = 0; ox < W; ++ox) {
      float acc = 0.0f;
      for (int ky = 0; ky < K; ++ky)
        for (int kx = 0; kx < K; ++kx)
          acc += in[(oy + ky) * in_stride + (ox + kx)] * ker[ky * K + kx];
      out[oy * W + ox] = acc;
    }
  }
}

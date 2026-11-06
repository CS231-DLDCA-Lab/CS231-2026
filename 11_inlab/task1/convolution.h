// convolution.h  shared interface for the 2D convolution stages (DLDCA 11_inlab, Task 1)
//
// Single-channel 2D convolution of a float32 image with a K x K kernel, zero-padded
// "same" mode, so the output is the same size as the input (this is cross-correlation:
// the kernel is not flipped).
//
//   in  : PADDED input, (H + 2p) rows x (W + 2p) cols, row-major, row stride = W + 2p,
//         where p = K / 2. The p-wide border is zero, so every read inside the loops is
//         in bounds and no boundary check is needed.
//   out : output, H rows x W cols, row-major, row stride = W.
//   ker : kernel, K x K, row-major.
//
//   out[y*W + x] = sum over ky, kx of  in[(y+ky)*(W+2p) + (x+kx)] * ker[ky*K + kx]
//
// W is a multiple of 4, so a 4-wide SSE inner loop over x has no remainder tail.
// K is odd (3 and 5 are used).

#ifndef DLDCA_CONVOLUTION_H
#define DLDCA_CONVOLUTION_H

// The stage under test. Each task1/conv_<stage>.cpp defines this one function; the
// harness (main.cpp) times it and checks it against its own reference.
void conv(const float* in, float* out, const float* ker, int H, int W, int K);

#endif

// conv_unroll.cpp  STAGE 3: unrolling for independent work.  (TODO)
//
// Stage 2 loads and stores the output row on every kernel tap. Instead, take a block of
// 16 output columns and keep its partial sums in 4 vector accumulators (registers)
// while the kernel loops run; store them once at the end. The 4 add chains are
// independent, so several adds are in flight at once and their latency is hidden.
// Add a 4-wide tail (one accumulator) for the last groups of columns.
//
// Register pressure: 4 accumulators plus the input and weight fit in the 16 SSE
// registers. Many more accumulators would spill to memory, so keep the unroll small.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

// conv_unroll.cpp  STAGE 3: unrolling for independent work.  (TODO)
//
// One vector accumulator is still a single dependency chain. Keep 4 vector accumulators
// (16 output columns) updated by 4 independent add chains, so several adds are in flight
// at once and their latency is hidden. Add a 4-wide tail for the last groups.
//
// Register pressure: 4 accumulators plus the input and weight fit in the 16 SSE
// registers. Many more accumulators would spill to memory, so keep the unroll small.

#include <xmmintrin.h>

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

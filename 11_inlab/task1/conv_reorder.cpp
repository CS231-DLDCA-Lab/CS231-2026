// conv_reorder.cpp  STAGE 1: a better loop order.  (TODO)
//
// Loop interchange: put the two kernel loops (ky, kx) outside and the loop over the
// columns (ox) inside. For one kernel weight, sweep the whole output row with
// o[ox] += ir[ox] * k, where ir points at the matching input row. Clear the output
// row to zero first. No new variables per pixel, no unrolling.

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

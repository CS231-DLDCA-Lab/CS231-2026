// conv_reorder.cpp  STAGE 1: a better loop order.  (TODO)
//
// Work on a group of 4 neighbouring output columns together. For each kernel weight,
// load 4 input values and update 4 independent running sums; write the 4 outputs once
// at the end. No single long dependency chain, and each output is written only once.

#include "convolution.h"

void conv(const float* in, float* out, const float* ker, int H, int W, int K)
{
  // TODO
}

// main.cpp  test / timing harness for Task 1.  PROVIDED, do not edit.
//
// Each conv_<stage>.out links this file with one conv_<stage>.cpp, so the binary runs
// only that stage's kernel. It builds a fixed random image, times the kernel over
// several repetitions (reporting the median), and checks the result against its own reference.
//
//   ./conv_reorder.out            # default 2048 x 2048, K = 3
//   ./conv_reorder.out 1024 1024 5
//   ./conv_reorder.out 2048 2048 3 50   # ... and 50 timed repetitions
//
// Measure one stage with perf, e.g.:  perf stat -d ./conv_simd.out

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <chrono>
#include <vector>

#include "convolution.h"

// The reference. Independent of the stage under test, so every binary self-checks.
static void reference(const float* in, float* out, const float* ker, int H, int W, int K)
{
  const int p = K / 2, in_stride = W + 2 * p;
  for (int oy = 0; oy < H; ++oy)
    for (int ox = 0; ox < W; ++ox) {
      float acc = 0.0f;
      for (int ky = 0; ky < K; ++ky)
        for (int kx = 0; kx < K; ++kx)
          acc += in[(oy + ky) * in_stride + (ox + kx)] * ker[ky * K + kx];
      out[oy * W + ox] = acc;
    }
}

int main(int argc, char** argv)
{
  int H = argc > 1 ? atoi(argv[1]) : 2048;
  int W = argc > 2 ? atoi(argv[2]) : 2048;
  int K = argc > 3 ? atoi(argv[3]) : 3;
  int reps = argc > 4 ? atoi(argv[4]) : 20;
  if (W % 4 != 0 || K % 2 == 0 || H <= 0 || W <= 0 || K <= 0 || reps <= 0) {
    fprintf(stderr, "need W a multiple of 4, K odd, positive sizes and reps\n");
    return 1;
  }
  const int p = K / 2, in_stride = W + 2 * p;
  const size_t in_n = (size_t)(H + 2 * p) * in_stride, out_n = (size_t)H * W;

  float* in  = (float*)aligned_alloc(64, in_n * sizeof(float));
  float* out = (float*)aligned_alloc(64, out_n * sizeof(float));
  float* ref = (float*)aligned_alloc(64, out_n * sizeof(float));
  float* ker = (float*)malloc((size_t)K * K * sizeof(float));

  srand(1234);
  memset(in, 0, in_n * sizeof(float));                 // keep the zero padding
  for (int y = 0; y < H; ++y)
    for (int x = 0; x < W; ++x)
      in[(y + p) * in_stride + (x + p)] = rand() / (float)RAND_MAX;
  for (int i = 0; i < K * K; ++i) ker[i] = rand() / (float)RAND_MAX;

  reference(in, out, ker, H, W, K);
  memcpy(ref, out, out_n * sizeof(float));

  // correctness
  memset(out, 0, out_n * sizeof(float));
  conv(in, out, ker, H, W, K);
  double maxerr = 0;
  for (size_t i = 0; i < out_n; ++i) {
    double d = out[i] - ref[i]; if (d < 0) d = -d;
    if (d > maxerr) maxerr = d;
  }

  // timing
  for (int i = 0; i < 2; ++i) conv(in, out, ker, H, W, K);   // warmup
  // time each repetition on its own and report the median, so one slow run
  // (an interrupt, a frequency change) does not move the result
  std::vector<double> times(reps);
  for (int i = 0; i < reps; ++i) {
    auto t0 = std::chrono::high_resolution_clock::now();
    conv(in, out, ker, H, W, K);
    auto t1 = std::chrono::high_resolution_clock::now();
    times[i] = std::chrono::duration<double, std::milli>(t1 - t0).count();
  }
  std::sort(times.begin(), times.end());
  double ms = reps % 2 ? times[reps / 2] : (times[reps / 2 - 1] + times[reps / 2]) / 2;
  double gflops = 2.0 * out_n * K * K / (ms * 1e6);

  printf("%d x %d, K=%d, %d reps\n", H, W, K, reps);
  printf("time:    %.3f ms (median of %d)\n", ms, reps);
  printf("GFLOP/s: %.2f\n", gflops);
  printf("%s (max abs error %.3g)\n", maxerr < 1e-3 ? "PASS" : "FAIL", maxerr);
  free(in); free(out); free(ref); free(ker);
  return maxerr < 1e-3 ? 0 : 1;
}

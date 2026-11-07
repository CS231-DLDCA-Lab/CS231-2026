# Task 1 explainer (instructor copy)

Reference answers for `questions.txt`. Numbers are per call of `conv()` at 2048 x 2048, K=3
(millions), from `perf stat taskset -c 1 ./conv_<stage>.out` on the solution files with the
harness's constant cost removed. Times differ per machine, but the ratios should hold.

| stage   | instructions | cycles | IPC | branches | L1 loads | time (ms) | speedup |
|---------|-------------:|-------:|----:|---------:|---------:|----------:|--------:|
| naive   | 382 | 63.8 | 6.0 | 62 | 85  | 12.1 | 1.0x |
| reorder | 282 | 54.5 | 5.2 | 42 | 119 | 10.0 | 1.2x |
| simd    |  93 | 25.9 | 3.6 | 13 | 36  |  3.8 | 3.2x |
| unroll  |  71 | 20.8 | 3.4 |  7 | 20  |  2.6 | 4.6x |

Time is `cycles = instructions / IPC`. IPC falls in every stage, but instructions fall by more,
so the code gets faster. Naive already runs at IPC 6, so it is limited by how many instructions
it executes, not by waiting. Each stage does the same work with fewer instructions.

## Why this loop order

Of the loop orders we tried, `oy, ky, kx, ox` is the best:

| order | time (ms) | instructions (M) | L1 misses (M) |
|-------|----------:|-----------------:|--------------:|
| `oy, ox, ky, kx` (naive) | 12.1 | 382 | 0.9 |
| `oy, ky, kx, ox` (ours)  | 10.0 | 282 | 0.7 |
| `ky, kx, oy, ox`         | 11.4 | 319 | 4.7 |
| `oy, ky, ox, kx`         | 17.8 | 344 | 0.7 |

`ox` must be innermost. It is the contiguous direction, so the loop walks consecutive floats and
is as long as the image is wide. With `kx` innermost the loop has 3 iterations, so the loop test,
address calculation and weight load are repeated every few multiplies (last row: slower than naive).

`oy` must stay outside `ky, kx`. Then one output row and its 3 input rows are reused by all 9
taps and stay in L1. With the kernel loops outside, each tap sweeps the whole 16 MB output and
input, so nothing stays cached between taps (third row: 7x the misses).

### Counting misses

Take K=3, N large, and 4-byte floats, so a 64 B line holds L=16 elements (L=8 for doubles). Along a
row, 1 access in L misses. Assume the cache holds a handful of rows (5 or 6) but not a whole image.
Every order does the same N^2 K^2 multiply-adds, so only the misses differ.

* `oy, ox, ky, kx` and `oy, ky, kx, ox`: we walk 3 input rows and 1 output row, which fit. Each
  line of `in` and `out` is loaded once: 2 N^2 / L misses. The reorder saves instructions, not misses.
* `ky, kx, oy, ox`: each of the 9 taps reloads both images: K^2 x 2 N^2 / L, 9 times more.
* `ox, oy, ky, kx` (down the columns): each step jumps a row and touches new lines. N lines have
  been touched before a column's lines are needed again, so almost every access misses: 2 N^2, L
  times more than the row-wise orders.

Measured L1 load misses per call divided by N^2 / L (so 2 means each line loaded once):

| order | predicted | N=1024 | N=2048 | N=4096 |
|-------|----------:|-------:|-------:|-------:|
| `oy, ox, ky, kx` (naive) | 2  | 2.5  | 3.6  | 4.0  |
| `oy, ky, kx, ox` (ours)  | 2  | 2.1  | 2.5  | 6.2  |
| `ky, kx, oy, ox`         | 18 | 18.1 | 18.1 | 18.1 |
| `ox, oy, ky, kx`         | 32 | 35.8 | 37.4 | 73   |

The model holds at N=1024 and drifts after that because of the 32 KB L1. A row takes 4N bytes,
so 4 rows take 16 KB at N=1024 (fit), 32 KB at N=2048 (all of L1, so some get evicted early) and
64 KB at N=4096 (no longer fit, so the input rows come back from L2 between taps). The
assumption holds only up to N of about 1500. The kernel-outermost count is already the worst
case, so it does not change with N. We did not look into why the column order is twice the model
at N=4096. It is also the slowest, at about 36 ms per call at N=2048.

All counts grow as N^2. The loop order sets the constant: 2/L when each line is loaded once,
K^2 x 2/L when the images are reloaded per tap, 2 when every access misses.

## Q1. naive -> reorder

Instructions fall from 382M to 282M, branches from 62M to 42M, and cycles from 63.8M to 54.5M.
IPC drops from 6.0 to 5.2.

In the naive code the innermost loop runs only 3 times. For every tap of every pixel we pay for
the loop test, the address calculation and the weight load. After the reorder, `ox` is the inner
loop. The weight and the input row pointer stay fixed for the whole row, so we pay for them once
per row. The arithmetic is the same: one multiply and one add per tap.

L1 loads get worse, from 85M to 119M. The running sum now lives in `o[ox]` in memory, so every
tap loads and stores it. This is why the gain is only 1.2x.

## Q2. naive -> simd

Instructions fall from 382M to 93M, branches from 62M to 13M, L1 loads from 85M to 36M, and
cycles from 63.8M to 25.9M. IPC drops from 6.0 to 3.6.

One SSE register holds 4 floats. One load, multiply, add and store now handle 4 columns, so the
inner loop runs a quarter of the iterations and the instruction count falls by about 4x. It is
a little under 4x because the loop control and the weight broadcast remain. Cycles fall by
2.5x, less than the instructions, because IPC went down.

## Q3. naive -> unroll

Instructions fall from 382M to 71M, branches from 62M to 7M, L1 loads from 85M to 20M, and
cycles from 63.8M to 20.8M. IPC drops from 6.0 to 3.4.

Compared with simd, we keep the 16 output columns in 4 registers while the 9 taps run, and store
them once at the end. This removes the load and store of `o[]` on every tap. The weight
broadcast and the loop control are now shared by 16 columns instead of 4. The 4 accumulators
are also independent, so their adds can overlap.

Four accumulators, one input vector and one weight use 6 of the 16 SSE registers. More
accumulators would need more registers, and past 16 the compiler would spill them to memory.

## Q4. What did not improve

IPC goes down in every stage (6.0, 5.2, 3.6, 3.4). Each remaining instruction does more work, so
the core finishes fewer of them per cycle. IPC alone does not rank the stages. Instructions
divided by IPC does.

L1 loads go up in reorder, as explained in Q1.

Branch misses stay at about 2M in every stage, and L1 load misses stay at about 20M. Neither
changes, so neither can explain a speedup. Most of the misses come from the harness (the
reference run and the first touch of the arrays). At K=3 the image is read row by row, so the
stages do not change the miss count much.

#include "kernels.h"

// i, j: the inner loop walks row i of A with stride 1.
void colsum_fast(const int* A, int N, int* s) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            s[j] += A[(size_t)i * N + j];
}

// i, j, k: the inner loop walks row i of A and row j of B with stride 1.
// The local sum keeps C[i][j] out of memory inside the loop.
void abt_fast(const int* A, const int* B, int N, int* C) {
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            int sum = 0;
            for (int k = 0; k < N; k++)
                sum += A[(size_t)i * N + k] * B[(size_t)j * N + k];
            C[(size_t)i * N + j] += sum;
        }
}

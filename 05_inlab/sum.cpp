// compile with:
// $(CXX) -O1 -fno-asynchronous-unwind-tables -fomit-frame-pointer -S sum.c -o sum.s
// where CXX=clang++/g++
// try -O0 and -O1

__attribute__((noinline)) float scale_add(float a, float b) {       // leaf
    return a * 3.0f + b;
}

int sum_loop(float *arr, int n) {     // caller: has a value (total) live ACROSS the call
    float total = 0;
    for (int i = 0; i < n; i++) {
        total += scale_add(arr[i], i);   // total must survive this call
    }
    return total;
}
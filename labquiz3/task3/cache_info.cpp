// Q3: Measuring Cache Parameters (TODO)
// Use only the functions of cache in cache.h: read, reset, remove_from_l1 and remove_from_l2.
// Part (c), 4 marks: Parts (a) and (b) fully correct, and Part (b) never calls remove_from_l1 / remove_from_l2.
#include "cache.h"
#include <cstdio>

// ---------------------------------------------------------------- Part A
// Fill in the values you measured on the cache of your roll number
// (make task3 args="read <your-roll-no> ..." or make task3 args="probe_parta <your-roll-no>").
cache_info part_a() {
    cache_info info{};
    info.cache_line_size = 0; // TODO
    info.l1_cache_size   = 0; // TODO (bytes)
    info.l1_num_way      = 0; // TODO
    info.l1_latency      = 0; // TODO
    info.l2_cache_size   = 0; // TODO (bytes)
    info.l2_num_way      = 0; // TODO
    info.l2_latency      = 0; // TODO
    info.dram_latency    = 0; // TODO
    return info;
}

// ---------------------------------------------------------------- probe_parta: NOT GRADED
// A scratchpad for your own experiments, to help you with Part A. It is NOT graded: write anything
// here, or nothing. make task3 args="probe_parta <your-roll-no>" (or demo) calls it once, on an empty
// cache, and then prints how many reads it made. Read from c in any pattern you like (loops, strides,
// c->reset(), c->remove_from_l1/l2) and print whatever you need with printf.
void probe_parta(cache* c) {
    // Example: the first read of address 0 comes from DRAM, the second hits in L1.
    // std::printf("read(0) = %u\n", c->read(0));
    // std::printf("read(0) = %u\n", c->read(0));
    (void)c;
}

// ---------------------------------------------------------------- Part B
// get_cache_info (in main.cpp) runs these eight functions in the order of find_order (at the end of
// this file). It calls c->reset() before each one, so every function starts from an EMPTY cache.
// Each one writes its own field into info, and may read the fields of the functions that run before
// it. You may add helper functions. The "May use" notes below assume the default order.

// Fills l1_latency. May use: nothing.
void find_l1_latency(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills l2_latency. May use: l1_latency.
void find_l2_latency(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills dram_latency. May use: l1_latency, l2_latency.
void find_dram_latency(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills cache_line_size. May use: the three latencies.
void find_line_size(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills l1_num_way. May use: the latencies, cache_line_size.
void find_l1_num_way(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills l1_cache_size (bytes). May use: the latencies, cache_line_size, l1_num_way.
void find_l1_cache_size(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills l2_num_way. May use: the latencies, cache_line_size, l1_num_way, l1_cache_size.
void find_l2_num_way(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// Fills l2_cache_size (bytes). May use: everything above, and l2_num_way.
void find_l2_cache_size(cache* c, cache_info& info) {
    // TODO
    (void)c; (void)info;
}

// The order in which get_cache_info runs the eight functions. Each must appear exactly once; you may
// change the order if your functions need the fields in a different order.
finder const find_order[8] = {
    find_l1_latency,
    find_l2_latency,
    find_dram_latency,
    find_line_size,
    find_l1_num_way,
    find_l1_cache_size,
    find_l2_num_way,
    find_l2_cache_size,
};

// Q3 reference solution (authors only).
#include "cache.h"
#include <cstdio>
#include <cstdlib>

// ---------------------------------------------------------------- Part A
// A student returns the eight numbers they measured. For the authors, this runs get_cache_info on the
// cache of $PART_A_ROLL (default 23b0900), so ./solution-make task3 args=a prints a real answer.
cache_info part_a() {
    const char* roll = std::getenv("PART_A_ROLL");
    std::unique_ptr<cache> c = make_part_a(roll ? roll : "23b0900");
    return get_cache_info(c.get());
}

// ---------------------------------------------------------------- probe_parta: NOT GRADED
// The students' scratchpad; the example from the stub, switched on.
void probe_parta(cache* c) {
    std::printf("read(0) = %u\n", c->read(0));
    std::printf("read(0) = %u\n", c->read(0));
}

// ---------------------------------------------------------------- Part B

// No level holds more than 128 MB, and line size and number of sets are powers of 2, so
// line * num_set divides 128 MB: addresses 128 MB apart are always in the same set.
static const std::uint32_t SAME_SET_STRIDE = 128u << 20;

// Reads n addresses `stride` bytes apart (0, stride, 2*stride, ...), then reads them all again.
// Returns true if every read of the second pass takes `latency` cycles.
// For L1: latency = l1_latency. For L2: latency = l2_latency, and every read is followed by
// remove_from_l1, so L1 never holds anything and each read goes to L2.
static bool fits(cache* c, std::uint32_t stride, std::uint32_t n, std::uint16_t latency, bool only_l2) {
    c->reset();
    for (std::uint32_t k = 0; k < n; ++k) {
        c->read(k * stride);
        if (only_l2) c->remove_from_l1(k * stride);
    }
    for (std::uint32_t k = 0; k < n; ++k) {
        std::uint16_t t = c->read(k * stride);
        if (only_l2) c->remove_from_l1(k * stride);
        if (t != latency) return false;
    }
    return true;
}

// The largest n for which fits() holds. If n lines fit, so do fewer, so: double n while it
// fits, then narrow down between the last n that fits and the first that does not.
static std::uint32_t most_that_fit(cache* c, std::uint32_t stride, std::uint16_t latency, bool only_l2) {
    std::uint32_t good = 1, bad = 2;
    while (fits(c, stride, bad, latency, only_l2)) {
        good = bad;
        bad  = bad * 2;
    }
    while (bad - good > 1) {
        std::uint32_t mid = good + (bad - good) / 2;
        if (fits(c, stride, mid, latency, only_l2)) good = mid;
        else bad = mid;
    }
    return good;
}

// Each function starts from an empty cache (get_cache_info resets it before every call).

// The second read of an address hits in L1.
void find_l1_latency(cache* c, cache_info& info) {
    c->read(0);
    info.l1_latency = c->read(0);
}

// After remove_from_l1, the line is in L2 only, so the next read hits in L2.
void find_l2_latency(cache* c, cache_info& info) {
    c->read(0);
    c->remove_from_l1(0);
    info.l2_latency = c->read(0);
}

// The first read of an address misses both levels.
void find_dram_latency(cache* c, cache_info& info) {
    info.dram_latency = c->read(0);
}

// Line size: after reading 0, the addresses 1, 2, ... hit in L1 until the first byte of the next line.
void find_line_size(cache* c, cache_info& info) {
    c->read(0);
    std::uint32_t line = 1;
    while (c->read(line) == info.l1_latency) ++line;
    info.cache_line_size = line;
}

// Ways: addresses 128 MB apart are all in one set, so as many of them fit as the set has ways.
void find_l1_num_way(cache* c, cache_info& info) {
    info.l1_num_way = most_that_fit(c, SAME_SET_STRIDE, info.l1_latency, false);
}

void find_l2_num_way(cache* c, cache_info& info) {
    info.l2_num_way = most_that_fit(c, SAME_SET_STRIDE, info.l2_latency, true);
}

// Size: consecutive lines go to consecutive sets, round and round, so they fill every set
// evenly: exactly num_set * num_way of them fit, which is size / line.
void find_l1_cache_size(cache* c, cache_info& info) {
    info.l1_cache_size = info.cache_line_size * most_that_fit(c, info.cache_line_size, info.l1_latency, false);
}

void find_l2_cache_size(cache* c, cache_info& info) {
    info.l2_cache_size = info.cache_line_size * most_that_fit(c, info.cache_line_size, info.l2_latency, true);
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

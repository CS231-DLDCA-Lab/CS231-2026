// Q3 reference solution for the bonus (authors only): never calls remove_from_l1 / remove_from_l2.
// Build and test it with:  ./solution-make SOL=_bonus_solution task3-check
#include "cache.h"
#include <cstdio>
#include <cstdlib>

// ---------------------------------------------------------------- Part A
// As in cache_info_solution.cpp: get_cache_info on the cache of $PART_A_ROLL (default 23b0900).
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
// For L1 (in_l2 = false): true if every read of the second pass hits in L1.
// For L2 (in_l2 = true):  true if no read of the second pass goes to DRAM. A line that L2 cannot
// keep also misses L1 (its L1 set gets at least as many of these lines as its L2 set, and L1 has
// fewer ways), so it comes from DRAM: no DRAM read means all n lines fit in L2.
static bool fits(cache* c, std::uint32_t stride, std::uint32_t n, const cache_info& info, bool in_l2) {
    c->reset();
    for (std::uint32_t k = 0; k < n; ++k) c->read(k * stride);
    for (std::uint32_t k = 0; k < n; ++k) {
        std::uint16_t t = c->read(k * stride);
        if (!in_l2 && t != info.l1_latency) return false;
        if (in_l2 && t == info.dram_latency) return false;
    }
    return true;
}

// The largest n for which fits() holds: double n while it fits, then narrow down.
static std::uint32_t most_that_fit(cache* c, std::uint32_t stride, const cache_info& info, bool in_l2) {
    std::uint32_t good = 1, bad = 2;
    while (fits(c, stride, bad, info, in_l2)) {
        good = bad;
        bad  = bad * 2;
    }
    while (bad - good > 1) {
        std::uint32_t mid = good + (bad - good) / 2;
        if (fits(c, stride, mid, info, in_l2)) good = mid;
        else bad = mid;
    }
    return good;
}

// The second read of an address hits in L1.
void find_l1_latency(cache* c, cache_info& info) {
    c->read(0);
    info.l1_latency = c->read(0);
}

// The first read of an address misses both levels.
void find_dram_latency(cache* c, cache_info& info) {
    info.dram_latency = c->read(0);
}

// After reading 0, the addresses 1, 2, ... hit in L1 until the first byte of the next line.
void find_line_size(cache* c, cache_info& info) {
    c->read(0);
    std::uint32_t line = 1;
    while (c->read(line) == info.l1_latency) ++line;
    info.cache_line_size = line;
}

void find_l1_num_way(cache* c, cache_info& info) {
    info.l1_num_way = most_that_fit(c, SAME_SET_STRIDE, info, false);
}

void find_l1_cache_size(cache* c, cache_info& info) {
    info.l1_cache_size = info.cache_line_size * most_that_fit(c, info.cache_line_size, info, false);
}

// Push line 0 out of L1 without removing it: read l1_num_way other lines of its L1 set (addresses
// k * line * l1_num_set). Line 0 stays in L2: if L2 has more sets, fewer of these lines share its L2
// set; if not, L2 has more ways. So the next read of 0 hits in L2. Needs the L1 results.
void find_l2_latency(cache* c, cache_info& info) {
    std::uint32_t l1_set_bytes = info.l1_cache_size / info.l1_num_way; // line * l1_num_set
    c->read(0);
    for (std::uint32_t k = 1; k <= info.l1_num_way; ++k) c->read(k * l1_set_bytes);
    info.l2_latency = c->read(0);
}

void find_l2_num_way(cache* c, cache_info& info) {
    info.l2_num_way = most_that_fit(c, SAME_SET_STRIDE, info, true);
}

void find_l2_cache_size(cache* c, cache_info& info) {
    info.l2_cache_size = info.cache_line_size * most_that_fit(c, info.cache_line_size, info, true);
}

// find_l2_latency needs the L1 results, so it runs after them.
finder const find_order[8] = {
    find_l1_latency,
    find_dram_latency,
    find_line_size,
    find_l1_num_way,
    find_l1_cache_size,
    find_l2_latency,
    find_l2_num_way,
    find_l2_cache_size,
};

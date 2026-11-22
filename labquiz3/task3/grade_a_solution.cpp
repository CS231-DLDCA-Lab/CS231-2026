// Q3 Part A grader (authors only). Compares part_a() of a student's cache_info.cpp with the true
// parameters of the cache of a roll number. Build and run:  ./solution-make grade-a ROLL=23b0950 ANS=...
// Prints one line per field and the number of correct fields.
#include "cache_solution.cpp"
#include <cstdio>

// The harness, for get_cache_info (a part_a() may call it); its main() is renamed out of the way.
#define main harness_main
#include "main.cpp"
#undef main

int main(int argc, char** argv) {
    if (argc != 2) { std::printf("usage: grade_a.out ROLL\n"); return 2; }
    std::string const roll = argv[1];
    gbnhmjvgf::ujmnhygt p{};
    try {
        std::string_view const r = gbnhmjvgf::okmijnuh(roll);
        p = gbnhmjvgf::ikmjunhy((gbnhmjvgf::yhnbgtrf(r) & ~std::uint64_t{0xfff}) | gbnhmjvgf::rfvtgbyh(r));
    } catch (const std::exception& e) {
        std::printf("%s\n", e.what());
        return 2;
    }

    cache_info const s = part_a();
    struct { const char* name; unsigned want, got; } const f[] = {
        {"cache_line_size", 1u << p.lg2_cache_line, s.cache_line_size},
        {"l1_cache_size",   (1u << p.lg2_cache_line) * (1u << p.lg2_l1_num_set) * p.l1_num_way, s.l1_cache_size},
        {"l1_num_way",      p.l1_num_way,           s.l1_num_way},
        {"l1_latency",      p.l1_latency,           s.l1_latency},
        {"l2_cache_size",   (1u << p.lg2_cache_line) * (1u << p.lg2_l2_num_set) * p.l2_num_way, s.l2_cache_size},
        {"l2_num_way",      p.l2_num_way,           s.l2_num_way},
        {"l2_latency",      p.l2_latency,           s.l2_latency},
        {"dram_latency",    p.dram_latency,         s.dram_latency},
    };
    bool right[8];
    for (int k = 0; k < 8; ++k) {
        right[k] = f[k].want == f[k].got;
        std::printf("%-16s want %8u  got %8u  %s\n", f[k].name, f[k].want, f[k].got, right[k] ? "OK" : "WRONG");
    }

    // Same marks as Part (b): each field on its own, 1 for each latency and the line size, 2 for each
    // size and number of ways.
    struct { const char* name; int marks; bool ok; } const g[] = {
        {"l1_latency",      1, right[3]},
        {"l2_latency",      1, right[6]},
        {"dram_latency",    1, right[7]},
        {"cache_line_size", 1, right[0]},
        {"l1_num_way",      2, right[2]},
        {"l1_cache_size",   2, right[1]},
        {"l2_num_way",      2, right[5]},
        {"l2_cache_size",   2, right[4]},
    };
    int marks = 0;
    for (auto const& x : g) {
        marks += x.ok ? x.marks : 0;
        std::printf("  %-27s %d/%d\n", x.name, x.ok ? x.marks : 0, x.marks);
    }
    std::printf("%s part (a): %d/12 marks\n", roll.c_str(), marks);
    return 0;
}

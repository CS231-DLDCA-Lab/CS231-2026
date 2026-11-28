#include "cache.h"
#include <bit>
#include <optional>
#include <span>
#include <stdexcept>
#include <string_view>
#include <utility>

namespace gbnhmjvgf {
    struct ghuytbdc {}; // l1-tag
    struct vgrtygfg {}; // l2-tag

    template<typename level_tag>
    struct gbvhfnjm { // cache level info
        std::uint32_t* const m_data;
        std::uint16_t const lg2_num_set;
        std::uint16_t const num_way;
        std::uint16_t const lg2_cache_line;


        // data layout: [ active_ways, LRU, LRU+1, ... MRU, *, *, ... * ] * num_set
        gbvhfnjm(std::uint16_t lg2_num_set, std::uint16_t num_way, std::uint16_t lg2_cache_line)
            : m_data(new std::uint32_t[(1 << lg2_num_set) * (num_way + 1)]), lg2_num_set(lg2_num_set), num_way(num_way), lg2_cache_line(lg2_cache_line) {
            reset();
        }
        ~gbvhfnjm() { delete[] m_data; }

        gbvhfnjm(const gbvhfnjm&)            = delete;
        gbvhfnjm(gbvhfnjm&&)                 = delete;
        gbvhfnjm& operator=(const gbvhfnjm&) = delete;
        gbvhfnjm& operator=(gbvhfnjm&&)      = delete;

        __attribute__((noinline)) void reset() noexcept {
            for (std::uint16_t num_set = this->num_set(), set = 0; set < num_set; ++set) {
                size(set) = 0;
            }
        }

        __attribute__((always_inline)) [[nodiscard]] std::uint16_t num_set() noexcept { return 1 << lg2_num_set; }
        __attribute__((always_inline)) [[nodiscard]] std::uint32_t* data(std::uint16_t set) noexcept { return m_data + set * (num_way + 1) + 1; }
        __attribute__((always_inline)) [[nodiscard]] std::uint32_t& size(std::uint16_t set) noexcept { return m_data[set * (num_way + 1)]; }
        __attribute__((always_inline)) [[nodiscard]] std::uint16_t set(std::uint32_t addr) noexcept { return (addr >> lg2_cache_line) & (num_set() - 1); }
        __attribute__((always_inline)) [[nodiscard]] std::uint32_t tag(std::uint32_t addr) noexcept { return (addr >> (lg2_cache_line + lg2_num_set)); }

        // present? -> promote
        __attribute__((noinline)) [[nodiscard]] bool ugvjbk(std::uint32_t addr) noexcept {
            std::uint16_t set = this->set(addr);
            std::uint32_t tag = this->tag(addr);

            std::uint32_t* data   = this->data(set);
            std::uint16_t num_way = this->size(set);
            std::uint16_t way     = 0;

            bool found = false;
            for (; way < num_way; ++way) {
                if (tag == data[way]) {
                    found = true;
                    break;
                }
            }

            if (!found) return false;

            for (++way; way < num_way; ++way) data[way - 1] = data[way];
            data[num_way - 1] = tag;

            return true;
        }

        // insert; optional return = evicted
        // pre(!present(addr))
        __attribute__((noinline)) [[nodiscard]] std::optional<std::uint32_t> evrgtx(std::uint32_t addr) noexcept {
            std::uint16_t set = this->set(addr);
            std::uint32_t tag = this->tag(addr);

            if (size(set) != num_way) {
                data(set)[size(set)++] = tag; // insert at the end
                return std::nullopt;
            }

            std::uint32_t* data   = this->data(set);
            std::uint32_t lru_tag = data[0];

            for (std::uint16_t way = 1; way < num_way; ++way) data[way - 1] = data[way];
            data[num_way - 1] = tag;

            return ((lru_tag << lg2_num_set) | set) << lg2_cache_line;
        }

        __attribute__((noinline)) void rcrdcd(std::uint32_t addr) noexcept {
            std::uint16_t set = this->set(addr);
            std::uint32_t tag = this->tag(addr);

            std::uint32_t* data   = this->data(set);
            std::uint32_t& num_way = this->size(set);

            uint16_t way = 0;
            bool found   = false;
            for (; way < num_way; ++way) {
                if (tag == data[way]) {
                    found = true;
                    break;
                }
            }
            if (!found) return;
            for (++way; way < num_way; ++way) data[way - 1] = data[way];
            num_way--;
        }
    };

    struct tyhhgcty {}; // part-a tag
    struct rtyvvjhu {}; // part-b tag

    template<typename part_tag>
    struct ecryhuni : cache {
        gbvhfnjm<std::pair<part_tag, ghuytbdc>> l1;
        gbvhfnjm<std::pair<part_tag, vgrtygfg>> l2;

        std::uint16_t l1_latency;
        std::uint16_t l2_latency;
        std::uint16_t dram_latency;

        ecryhuni(std::uint16_t lg2_cache_line, std::uint16_t lg2_l1_num_set, std::uint16_t val_l1_num_way, std::uint16_t val_l1_latency,
                 std::uint16_t lg2_l2_num_set, std::uint16_t val_l2_num_way, std::uint16_t val_l2_latency, std::uint16_t val_dram_latency)
            : l1(lg2_l1_num_set, val_l1_num_way, lg2_cache_line), l2(lg2_l2_num_set, val_l2_num_way, lg2_cache_line), //
              l1_latency(val_l1_latency), l2_latency(val_l2_latency), dram_latency(val_dram_latency) {}

        // computed from the levels, so the object keeps its size
        cache_info params() const noexcept override {
            std::uint32_t const line = 1u << l1.lg2_cache_line;
            return {std::uint16_t(line), (line << l1.lg2_num_set) * l1.num_way, l1.num_way, l1_latency,
                    (line << l2.lg2_num_set) * l2.num_way, l2.num_way, l2_latency, dram_latency};
        }

        // NINE, no write-backs: a miss fills L2 (if it missed there) and L1; a victim of either level is
        // dropped. Both levels are LRU; L2 sees only the reads that miss L1.
        std::uint16_t read(std::uint32_t addr) noexcept override {
            if (l1.ugvjbk(addr)) return l1_latency;

            std::uint16_t latency = l2_latency;
            if (!l2.ugvjbk(addr)) {
                static_cast<void>(l2.evrgtx(addr)); // fill L2 from DRAM
                latency = dram_latency;
            }

            static_cast<void>(l1.evrgtx(addr)); // fill L1; its victim is dropped (no write-back)

            return latency;
        }

        void reset() noexcept override {
            l1.reset();
            l2.reset();
        }

        void remove_from_l1(std::uint32_t addr) noexcept override {
            l1.rcrdcd(addr);
        }
        void remove_from_l2(std::uint32_t addr) noexcept override {
            l2.rcrdcd(addr);
        }
    };

    static_assert(sizeof(ecryhuni<tyhhgcty>) == 48);

    // always-on check (assert() vanishes under NDEBUG)
    inline void hbgvfrtd(bool ok, const char* what) {
        if (!ok) throw std::invalid_argument(what);
    }

    // roll-number check: after trimming surrounding whitespace it must be exactly 2Nbxxxx (lowercase b) with
    // N in 3..5 and xxxx in 0900..1200 (903 roll numbers), or the one exception 210050102.
    // Returns the trimmed roll number; throws otherwise.
    inline std::string_view okmijnuh(std::string const& roll_num) {
        auto is_space = [](char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r'; };
        std::string_view s(roll_num);
        while (!s.empty() && is_space(s.front())) s.remove_prefix(1);
        while (!s.empty() && is_space(s.back())) s.remove_suffix(1);

        if (s == "210050102") return s;

        bool ok = s.size() == 7 && s[0] == '2' && s[1] >= '3' && s[1] <= '5' && s[2] == 'b';
        int num = 0;
        for (std::size_t i = 3; ok && i < 7; ++i) {
            ok  = s[i] >= '0' && s[i] <= '9';
            num = num * 10 + (s[i] - '0');
        }
        ok = ok && num >= 900 && num <= 1200;

        if (!ok) throw std::invalid_argument("make_part_a: roll number must be 2Nb0900..2Nb1200 (lowercase b, N = 3, 4 or 5), got '" + roll_num + "'");
        return s;
    }

    // roll-number hash: FNV-1a 64 over the canonical roll number, then the splitmix64 finaliser so every
    // output bit depends on every input byte. Fully specified (unlike std::hash), so a roll number gives
    // the same cache on every machine. Supplies the latency bits; the geometry bits come from rfvtgbyh.
    inline std::uint64_t yhnbgtrf(std::string_view roll_num) noexcept {
        std::uint64_t h = 0xcbf29ce484222325ull;
        for (unsigned char c : roll_num) {
            h ^= c;
            h *= 0x100000001b3ull;
        }
        h ^= h >> 30;
        h *= 0xbf58476d1ce4e5b9ull;
        h ^= h >> 27;
        h *= 0x94d049bb133111ebull;
        h ^= h >> 31;
        return h;
    }

    // 12 geometry bits, distinct for every valid roll number: no hash into 4096 values can avoid collisions
    // over ~900 roll numbers, so these bits are a one-to-one function of the roll number itself.
    // code = (year digit & 3) << 10 | (number & 1023): years 3, 4, 5 -> 3, 0, 1; numbers 0900..1200 -> 900..1023,
    // 0..176, all different. The exception takes the unused year value 2. The code is then scrambled by
    // invertible 12-bit steps (odd multiply, xor with own right shift), so neighbours get unrelated shapes.
    // pre: roll_num passed okmijnuh
    inline std::uint64_t rfvtgbyh(std::string_view roll_num) noexcept {
        std::uint32_t code;
        if (roll_num.size() != 7) {
            code = (2u << 10) | 102u; // 210050102
        } else {
            std::uint32_t num = 0;
            for (std::size_t i = 3; i < 7; ++i) num = num * 10 + static_cast<std::uint32_t>(roll_num[i] - '0');
            code = ((static_cast<std::uint32_t>(roll_num[1] - '0') & 3u) << 10) | (num & 1023u);
        }

        code = (code * 0x5bdu) & 0xfffu;
        code ^= code >> 6;
        code = (code * 0x9e3u) & 0xfffu;
        code ^= code >> 5;
        code = (code * 0x2adu) & 0xfffu;
        return code;
    }

    struct ujmnhygt { // part-a parameters, as lg2 for line size and set counts
        std::uint16_t lg2_cache_line;
        std::uint16_t lg2_l1_num_set, l1_num_way, l1_latency;
        std::uint16_t lg2_l2_num_set, l2_num_way, l2_latency;
        std::uint16_t dram_latency;
    };

    // Each field takes the next low bits of the hash (25 bits in all). Every value is built on the one
    // before it, so all make_part_b rules hold by construction:
    //   line 16..128 B, L1 8..64 sets x 1..8 ways, L2 = 2x..16x the L1 sets x (L1 ways + 0..7) ways,
    //   so L2 has strictly more lines; L2 storage is at most 1024 * 16 words.
    //   latency: L1 2..5, L2 = L1 + 6..21, DRAM = L2 + 50..177.
    inline ujmnhygt ikmjunhy(std::uint64_t h) noexcept {
        auto take = [&h](unsigned bits) {
            auto v = static_cast<std::uint16_t>(h & ((1u << bits) - 1));
            h >>= bits;
            return v;
        };

        ujmnhygt p{};
        p.lg2_cache_line = 4 + take(2);
        p.lg2_l1_num_set = 3 + take(2);
        p.l1_num_way     = 1 + take(3);
        p.lg2_l2_num_set = p.lg2_l1_num_set + 1 + take(2);
        p.l2_num_way     = p.l1_num_way + take(3);
        p.l1_latency     = 2 + take(2);
        p.l2_latency     = p.l1_latency + 6 + take(4);
        p.dram_latency   = p.l2_latency + 50 + take(7);
        return p;
    }
} // namespace gbnhmjvgf

// throws std::invalid_argument for a bad roll number
std::unique_ptr<cache> make_part_a(std::string roll_num) {
    std::string_view const roll = gbnhmjvgf::okmijnuh(roll_num);
    // low 12 bits (geometry) from rfvtgbyh, the rest (latencies) from the hash
    std::uint64_t const bits    = (gbnhmjvgf::yhnbgtrf(roll) & ~std::uint64_t{ 0xfff }) | gbnhmjvgf::rfvtgbyh(roll);
    gbnhmjvgf::ujmnhygt const p = gbnhmjvgf::ikmjunhy(bits);
    return std::make_unique<gbnhmjvgf::ecryhuni<gbnhmjvgf::tyhhgcty>>(p.lg2_cache_line, p.lg2_l1_num_set, p.l1_num_way, p.l1_latency, p.lg2_l2_num_set,
                                                                      p.l2_num_way, p.l2_latency, p.dram_latency);
}

std::unique_ptr<cache> make_part_b(std::uint16_t cache_line_size, std::uint16_t l1_num_set, std::uint16_t l1_num_way, std::uint16_t l1_latency,
                                   std::uint16_t l2_num_set, std::uint16_t l2_num_way, std::uint16_t l2_latency, std::uint16_t dram_latency) {
    using gbnhmjvgf::hbgvfrtd;

    hbgvfrtd(std::has_single_bit(cache_line_size), "make_part_b: cache_line_size must be a power of two");
    // with the storage cap below (fewer than 2^20 lines per level), this keeps every level under 128 MB
    hbgvfrtd(cache_line_size <= 128, "make_part_b: cache_line_size must be at most 128");
    hbgvfrtd(std::has_single_bit(l1_num_set), "make_part_b: l1_num_set must be a power of two");
    hbgvfrtd(std::has_single_bit(l2_num_set), "make_part_b: l2_num_set must be a power of two");

    hbgvfrtd(l1_num_way >= 1, "make_part_b: l1_num_way must be at least 1");
    hbgvfrtd(l1_num_set <= l2_num_set, "make_part_b: need l1_num_set <= l2_num_set");
    hbgvfrtd(l1_num_way <= l2_num_way, "make_part_b: need l1_num_way <= l2_num_way");
    hbgvfrtd(l2_num_way <= 15, "make_part_b: l2_num_way must be at most 15");

    std::uint64_t const l1_lines = std::uint64_t(l1_num_set) * l1_num_way;
    std::uint64_t const l2_lines = std::uint64_t(l2_num_set) * l2_num_way;
    hbgvfrtd(l1_lines < l2_lines, "make_part_b: need l1_num_set * l1_num_way < l2_num_set * l2_num_way");
    // storage is num_set * (num_way + 1) words per level; also keeps the int product in the constructor in range
    hbgvfrtd(std::uint64_t(l2_num_set) * (l2_num_way + 1u) <= (1u << 20), "make_part_b: l2_num_set * (l2_num_way + 1) must be at most 2^20");

    hbgvfrtd(l1_latency < l2_latency, "make_part_b: need l1_latency < l2_latency");
    hbgvfrtd(l2_latency < dram_latency, "make_part_b: need l2_latency < dram_latency");

    return std::make_unique<gbnhmjvgf::ecryhuni<gbnhmjvgf::rtyvvjhu>>(std::countr_zero(cache_line_size), std::countr_zero(l1_num_set), l1_num_way, l1_latency,
                                                                      std::countr_zero(l2_num_set), l2_num_way, l2_latency, dram_latency);
}

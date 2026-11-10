#ifndef SAMPLER_H
#define SAMPLER_H

#include <algorithm>
#include <cstdint>
#include <vector>

// ======================= DO NOT EDIT: observer sets =======================
// The predictor learns only from every 64th LLC set: 32 of the 2048 sets.
#define OBSERVER_STRIDE 64
inline bool is_observer(uint32_t set) { return set % OBSERVER_STRIDE == 0; }

// The signature of a block is the lower 14 bits of the PC that brought it in.
inline uint32_t signature(uint64_t ip) { return ip & 0x3FFF; }
// ==========================================================================

// Predictor size. Task 5 changes the counter width and the threshold from the make
// command line (make task5 COUNTER_BITS=3 THRESHOLD=20); keep these defaults for Tasks 2-4.
#define DBP_TABLES 3   // number of tables, one hash function each
#define DBP_ENTRIES 4096 // counters per table
#ifndef DBP_COUNTER_BITS
#define DBP_COUNTER_BITS 2
#endif
#ifndef DBP_THRESHOLD
#define DBP_THRESHOLD 8 // dead if the sum of the counters is > DBP_THRESHOLD
#endif
#define DBP_MAX_COUNT ((1 << DBP_COUNTER_BITS) - 1) // saturating counters: 0..DBP_MAX_COUNT

class DeadBlockPredictor
{
private:
  // ===================== DO NOT EDIT: hash functions =====================
  uint32_t hash1(uint32_t x) const
  {
    x ^= (x >> 16);
    x *= 0x7feb352d;
    x ^= (x >> 15);
    return x & 0xFFF; // 12-bit index (0-4095)
  }

  uint32_t hash2(uint32_t x) const
  {
    x ^= (x >> 13);
    x *= 0x846ca68b;
    x ^= (x >> 16);
    return x & 0xFFF;
  }

  uint32_t hash3(uint32_t x) const
  {
    x ^= (x << 7);
    x *= 0x165667b1;
    x ^= (x >> 11);
    return x & 0xFFF;
  }
  // ======================================================================

  // TODO 1 Task 2: one table of counters per hash function
  std::vector<std::vector<int>> counters;

public:
  // TODO 2 Task 2: every counter starts at 0
  DeadBlockPredictor() : counters(DBP_TABLES, std::vector<int>(DBP_ENTRIES, 0)) {}

  // true if blocks brought in by this signature are predicted dead
  bool predict_to_be_dead(uint32_t sig) const
  {
    // TODO 3 Task 2: add up the three counters this signature maps to, compare with DBP_THRESHOLD
    int sum = counters[0][hash1(sig)] + counters[1][hash2(sig)] + counters[2][hash3(sig)];
    return sum > DBP_THRESHOLD;
  }

  // dead = true: a block with this signature was evicted, count up
  // dead = false: a block with this signature got a hit, count down
  void update(uint32_t sig, bool dead)
  {
    // TODO 4 Task 2: update the three counters this signature maps to (they saturate at 0 and DBP_MAX_COUNT)
    uint32_t idx[DBP_TABLES] = {hash1(sig), hash2(sig), hash3(sig)};
    for (int t = 0; t < DBP_TABLES; t++) {
      int& c = counters[t][idx[t]];
      if (dead && c < DBP_MAX_COUNT)
        c++;
      else if (!dead && c > 0)
        c--;
    }
  }
};

#endif

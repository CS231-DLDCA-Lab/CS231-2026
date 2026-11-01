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

  // TODO 1 Task 2: declare the counter tables

public:
  // TODO 2 Task 2: initialize the counters
  DeadBlockPredictor() {}

  // true if blocks brought in by this signature are predicted dead
  bool predict_to_be_dead(uint32_t sig) const
  {
    // TODO 3 Task 2: predict using the counters
    return false;
  }

  // dead = true: a block with this signature was evicted, count up
  // dead = false: a block with this signature got a hit, count down
  void update(uint32_t sig, bool dead)
  {
    // TODO 4 Task 2: update the counters
  }
};

#endif

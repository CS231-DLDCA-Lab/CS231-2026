#include <map>
#include <vector>

#include "cache.h"

#define FILL_PERIOD 32

// One age per line, stored at index set * NUM_WAY + way, as in Task 1.
// NUM_WAY - 1 is the most recently used line, 0 the least recently used.
std::map<CACHE*, std::vector<uint32_t>> ages;

// Number of fills so far, counted from the last MRU insertion. One per cache.
std::map<CACHE*, uint32_t> fillCount;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  ages[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, 0);
  fillCount[this] = 0;
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // the least recently used line has age 0
  for (uint32_t i = 0; i < NUM_WAY; i++) {
    if (ages[this][set * NUM_WAY + i] == 0)
      return i;
  }

  assert(false); // unreachable: one line of the set always has age 0
  return 0;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the line in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // ---- DO NOT EDIT: the policy ignores translation and prefetch accesses ----
  if (type == TRANSLATION || type == PREFETCH)
    return;
  // ---- end of DO NOT EDIT ----

  bool toMRU = hit; // a hit always promotes the line to MRU; this being true implies normal LRU impl

  if (!hit) {
    // a fill: every FILL_PERIOD-th one goes to MRU, the others to LRU
    fillCount[this]++;
    if (fillCount[this] == FILL_PERIOD) {
      fillCount[this] = 0;
      toMRU = true;
    }
  }

  uint32_t currVal = ages[this][set * NUM_WAY + way];

  if (toMRU) {
    // typical LRU implementation
    for (uint32_t i = 0; i < NUM_WAY; i++) {
      if (ages[this][set * NUM_WAY + i] > currVal)
        ages[this][set * NUM_WAY + i]--;
    }
    ages[this][set * NUM_WAY + way] = NUM_WAY - 1;
  } else {
    // not typical LRU; insertion happening at LRU
    ages[this][set * NUM_WAY + way] = 0;
  }
}

// called once at the end of the simulation
void CACHE::replacement_final_stats() {}

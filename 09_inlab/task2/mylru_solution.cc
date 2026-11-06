#include <map>
#include <vector>

#include "cache.h"

// One age per line, stored at index set * NUM_WAY + way.
// The ages of a set are always 0 .. NUM_WAY - 1, each used once:
// NUM_WAY - 1 is the most recently used line, 0 the least recently used.
// The map gives every cache that uses this policy its own array.
std::map<CACHE*, std::vector<uint32_t>> lruBits;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  lruBits[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, 0);
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // the least recently used line has age 0
  for (uint32_t i = 0; i < NUM_WAY; i++) {
    if (lruBits[this][set * NUM_WAY + i] == 0)
      return i;
  }

  assert(false); // unreachable: one line of the set always has age 0
  return 0;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the line in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // a writeback hit is the upper cache handing back a dirty line, not a use by the program
  if (hit && type == WRITEBACK)
    return;

  uint32_t currVal = lruBits[this][set * NUM_WAY + way];

  // every line used more recently than this one gets one step older
  for (uint32_t i = 0; i < NUM_WAY; i++) {
    if (lruBits[this][set * NUM_WAY + i] > currVal)
      lruBits[this][set * NUM_WAY + i]--;
  }

  // this line is now the most recently used
  lruBits[this][set * NUM_WAY + way] = NUM_WAY - 1;
}

// called once at the end of the simulation
void CACHE::replacement_final_stats() {}

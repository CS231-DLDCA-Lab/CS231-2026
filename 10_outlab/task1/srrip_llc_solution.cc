#include <map>
#include <vector>

#include "cache.h"

#define maxRRPV 3

// TODO 1 Task 1: one RRPV per block, at index set * NUM_WAY + way
std::map<CACHE*, std::vector<uint32_t>> rrpv;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  // TODO 2 Task 1: every block starts at the distant end
  rrpv[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, maxRRPV);
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO 3 Task 1: evict the first block at maxRRPV; if there is none, age every block and look again
  std::vector<uint32_t>& r = rrpv[this];
  while (true) {
    for (uint32_t i = 0; i < NUM_WAY; i++)
      if (r[set * NUM_WAY + i] == maxRRPV)
        return i;

    for (uint32_t i = 0; i < NUM_WAY; i++)
      r[set * NUM_WAY + i]++;
  }
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  uint32_t& r = rrpv[this][set * NUM_WAY + way];

  // TODO 4 Task 1: hit promotion and insertion, plus the writeback rule
  if (hit) {
    if (type == WRITEBACK)
      return;        // a writeback hit is not a reuse: leave the RRPV as it is
    r = 0;           // hit promotion: predicted to be reused soon
  } else {
    if (type == WRITEBACK)
      r = maxRRPV;     // writeback fill: lowest priority
    else
      r = maxRRPV - 1; // insertion: long re-reference interval
  }
}

void CACHE::replacement_final_stats() {}

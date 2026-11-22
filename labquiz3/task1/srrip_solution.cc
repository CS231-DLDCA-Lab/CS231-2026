#include <map>
#include <vector>

#include "cache.h"

// ---- parameters: DO NOT EDIT (the reference numbers depend on them) ----
#define maxRRPV 7          // 3-bit RRPV: 0 .. 7
#define INSERT_RRPV 6      // a demand fill enters here (3-bit SRRIP)
// ---- END DO NOT EDIT ----

// CHANGED One RRPV per block of the cache, at index set * NUM_WAY + way.
std::map<CACHE*, std::vector<uint32_t>> rrpv;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  rrpv[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, maxRRPV);
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  std::vector<uint32_t>& r = rrpv[this];
  while (true) {
    for (uint32_t way = 0; way < NUM_WAY; way++) {
      if (r[set * NUM_WAY + way] == maxRRPV)
        return way;
    }

    for (uint32_t way = 0; way < NUM_WAY; way++) // no block at maxRRPV: age the set and look again
      r[set * NUM_WAY + way]++;
  }
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // TODO Task 1 part (a): the 3-bit SRRIP hit and fill rules (Step 1 of the PDF)
  uint32_t& r = rrpv[this][set * NUM_WAY + way];

  if (hit) {
    if (type == WRITEBACK)
      return;        // a writeback hit is not a reuse: leave the RRPV as it is
    r = 0;           // hit promotion: predicted to be reused soon
    return;
  }
  if (type == WRITEBACK) {
    r = maxRRPV;     // writeback fill: lowest priority
    return;
  }

  r = INSERT_RRPV;   // demand fill: 3-bit SRRIP insertion
}

void CACHE::replacement_final_stats() {}

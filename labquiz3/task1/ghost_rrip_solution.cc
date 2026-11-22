#include <algorithm>
#include <map>
#include <vector>

#include "cache.h"

// ---- parameters: DO NOT EDIT (the reference numbers depend on them) ----
#define maxRRPV 7          // 3-bit RRPV: 0 .. 7
#define INSERT_RRPV 6      // a demand fill enters here (3-bit SRRIP)
#define GHOST_RRPV 2       // a demand fill whose block is in the ghost list enters here
#define GHOST_LEN 16       // K: each set remembers its last 16 victims
#define GHOST_EMPTY UINT64_MAX // an empty slot of a ghost list (no real tag has this value)

// CHANGED The tag of addr: drop the block offset bits and the set index bits. Compare blocks of one set with this.
static uint64_t tag_of(uint64_t addr, uint32_t num_set) { return addr >> (LOG2_BLOCK_SIZE + lg2(num_set)); }
// ---- END DO NOT EDIT ----

// CHANGED One RRPV per block of the cache, at index set * NUM_WAY + way.
std::map<CACHE*, std::vector<uint32_t>> rrpv;

// TODO 1 Task 1 part (b): for every set, a list of GHOST_LEN slots with the tags of its last victims, oldest first
std::map<CACHE*, std::vector<std::vector<uint64_t>>> ghost;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  rrpv[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, maxRRPV);

  // TODO 2 Task 1 part (b): one ghost list per set, every slot GHOST_EMPTY
  ghost[this] = std::vector<std::vector<uint64_t>>(NUM_SET, std::vector<uint64_t>(GHOST_LEN, GHOST_EMPTY));
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  std::vector<uint32_t>& r = rrpv[this];
  while (true) {
    for (uint32_t way = 0; way < NUM_WAY; way++) {
      if (r[set * NUM_WAY + way] == maxRRPV) {
        // TODO 3 Task 1 part (b): remember the victim in this set's ghost list
        std::vector<uint64_t>& g = ghost[this][set];
        uint64_t victim = tag_of(current_set[way].address, NUM_SET);
        if (std::find(g.begin(), g.end(), victim) == g.end()) { // not if it is already in the list
          for (uint32_t i = 0; i + 1 < GHOST_LEN; i++)          // shift toward the front: the oldest (g[0]) drops out
            g[i] = g[i + 1];
          g[GHOST_LEN - 1] = victim;                            // newest at the back
        }
        return way;
      }
    }

    for (uint32_t way = 0; way < NUM_WAY; way++) // no block at maxRRPV: age the set and look again
      r[set * NUM_WAY + way]++;
  }
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // FIRST: your part (a) hit and fill rules, copied from task1/srrip.cc
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

  // TODO 4 Task 1 part (b): a demand fill whose tag is in this set's ghost list enters at GHOST_RRPV.
  // The entry stays in the list.
  std::vector<uint64_t>& g = ghost[this][set];
  if (std::find(g.begin(), g.end(), tag_of(full_addr, NUM_SET)) != g.end())
    r = GHOST_RRPV;
}

void CACHE::replacement_final_stats() {}

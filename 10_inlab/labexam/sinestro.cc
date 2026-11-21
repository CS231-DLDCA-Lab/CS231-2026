#include <map>
#include <vector>

#include "cache.h"

// TODO: Setup your data structures (counters, trackers etc.) here

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  // TODO: initialize your data structures
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO: write the logic to evict the least recently used line of the set
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

  // TODO: write the logic to promote the line on a hit, or insert it on a fill
}

// called once at the end of the simulation
void CACHE::replacement_final_stats() {}

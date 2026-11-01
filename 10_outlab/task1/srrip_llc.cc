#include <map>
#include <vector>

#include "cache.h"

#define maxRRPV 3

// TODO 1 Task 1: define a structure here that holds one RRPV for every block of the cache

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  // TODO 2 Task 1: give every block its starting RRPV
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO 3 Task 1: victim selection logic
  return 0;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // TODO 4 Task 1: promotion and insertion logic; handle writebacks as well
}

void CACHE::replacement_final_stats() {}

#include <map>
#include <vector>

#include "cache.h"

#define maxRRPV 3

// DRRIP parameters: DO NOT EDIT
#define PSEL_MAX 1023
#define BRRIP_INTERVAL 32
uint32_t PSEL = PSEL_MAX / 2;
uint32_t brrip_fills = 0;
static bool srrip_leader(uint32_t set) { return (set % 64) == 0; }
static bool brrip_leader(uint32_t set) { return (set % 64) == 1; }

// TODO 1 Task 2: define a structure here that holds one RRPV for every block of the cache

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  // TODO 2 Task 2: give every block its starting RRPV
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO 3 Task 2: victim selection logic
  return 0;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // TODO 4 Task 2: promotion logic; handle writebacks as well

  // TODO 5 Task 2: DRRIP, pick the insertion policy for this set and train PSEL

  // TODO 6 Task 2: DRRIP, insert the fill with that policy
}

void CACHE::replacement_final_stats() {}

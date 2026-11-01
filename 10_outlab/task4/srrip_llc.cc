#include <map>
#include <vector>

#include "cache.h"
#include "sampler.h"

extern DeadBlockPredictor dp_predictor; // defined in cache.cc

#define maxRRPV 3

// Copy your Task 1 code (TODO 1-4 Task 1) into this file

// called once before the simulation starts
void CACHE::initialize_replacement()
{
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO 1 Task 4: evict dead blocks first, then do the SRRIP loop
  return 0;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the block in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
}

void CACHE::replacement_final_stats() {}

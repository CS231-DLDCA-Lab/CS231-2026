#include <algorithm>
#include <iterator>
#include <map>

#include "cache.h"
#include "util.h"


std::map<CACHE*,std::vector<uint32_t>> lruBits;   // one age per line, as in Task 1
std::map<CACHE*,std::vector<uint32_t>> flipBits;  // one flip bit per set

void CACHE::initialize_replacement() {
    // TODO: NUM_SET * NUM_WAY ages and NUM_SET flip bits, all 0
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO:
  // 1. read the flip bit of this set, then flip it (0 -> 1, 1 -> 0)
  // 2. the bit you read is 0: evict the least recently used line
  //    the bit you read is 1: evict the most recently used line

  return 0;
}

// called on every cache hit and cache fill
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
    if(hit && type == WRITEBACK){
        return;
    } // we don't care about writebacks

    // TODO: same as Task 1
}

void CACHE::replacement_final_stats() {}

#include <algorithm>
#include <iterator>
#include <map>

#include "cache.h"
#include "util.h"


std::map<CACHE*,std::vector<uint32_t>> lruBits;
std::map<CACHE*,std::vector<uint32_t>> flipBits;

void CACHE::initialize_replacement() {
    lruBits[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY);
    flipBits[this] = std::vector<uint32_t>(NUM_SET);
    for(int i = 0; i < NUM_SET*NUM_WAY; i++){
        lruBits[this][i] = 0;
    }
    for(int i = 0; i< NUM_SET; i++){
        flipBits[this][i] = 0;
    }
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // baseline LRU

  uint8_t  flip = flipBits[this][set];

  flipBits[this][set] = 1 - flipBits[this][set];


  if(flip == 0){
    for(uint32_t i = 0; i < NUM_WAY; i++){
        if(lruBits[this][set*NUM_WAY + i] == 0){
            return i;
        }
    }
   }else{
    for(uint32_t i = 0; i < NUM_WAY; i++){
        if(lruBits[this][set*NUM_WAY + i] == NUM_WAY - 1){
            return i;
        }
    }
   }

  assert(false);
}

// called on every cache hit and cache fill
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
    if(hit && type == WRITEBACK){
        return;
    } // we don't care about writebacks

    uint32_t currVal = lruBits[this][set*NUM_WAY + way];
    //current lru value
    for(uint32_t i = 0; i < NUM_WAY;i++){
        if(currVal < lruBits[this][set*NUM_WAY + i]){
            lruBits[this][set*NUM_WAY + i]--;
        }//all the higher number (more recent) decrease by 1
    }
    lruBits[this][set*NUM_WAY + way] = NUM_WAY - 1; // now make this the most recently used
}

void CACHE::replacement_final_stats() {}

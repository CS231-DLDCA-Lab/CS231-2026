#include <map>
#include <vector>

#include "cache.h"

// One 8-bit counter per instruction, indexed by the lower 16 bits of its ip.
// A high count means lines brought in by that instruction are reused.
std::map<CACHE*, std::vector<uint8_t>> pcCount;

// index into pcCount: the lower 16 bits of the ip
uint32_t pc_index(uint64_t ip) { return ip & 0xFFFF; }

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  pcCount[this] = std::vector<uint8_t>(1 << 16, 0);
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // current_set[i].ip is the ip of the instruction that brought line i in.
  // Evict the line whose ip has the lowest count; on a tie, the lowest way.
  uint32_t victim = 0;
  for (uint32_t i = 1; i < NUM_WAY; i++) {
    if (pcCount[this][pc_index(current_set[i].ip)] < pcCount[this][pc_index(current_set[victim].ip)])
      victim = i;
  }
  return victim;
}

// called on every hit (hit = 1) and every fill (hit = 0) of the line in (set, way)
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  // a writeback hit is the upper cache handing back a dirty line, not a use by the program
  if (hit && type == WRITEBACK)
    return;

  uint8_t& count = pcCount[this][pc_index(ip)];

  if (hit) {
    // this instruction found its data: reward it, stop at 255
    if (count < 255)
      count++;
  } else {
    // this instruction missed: punish it, stop at 0
    if (count > 0)
      count--;
  }
}

// called once at the end of the simulation
void CACHE::replacement_final_stats() {}

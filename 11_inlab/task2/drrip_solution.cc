#include <map>
#include <vector>

#include "cache.h"

#define maxRRPV 3

// ---- DRRIP set-dueling parameters: DO NOT EDIT (the reference numbers depend on them) ----
#define PSEL_MAX 1023              // PSEL is a 10-bit saturating counter: 0 .. 1023
#define BRRIP_INTERVAL 32          // BRRIP inserts 1 in 32 fills at maxRRPV - 1
uint32_t PSEL = PSEL_MAX / 2;      // one counter for the whole cache, starts in the middle
uint32_t brrip_fills = 0;          // counts BRRIP insertions, for the 1-in-32 rule

// Leader sets, fixed by set index: 32 sets always use SRRIP, 32 always use BRRIP.
// Every other set is a follower.
static bool srrip_leader(uint32_t set) { return (set % 64) == 0; }
static bool brrip_leader(uint32_t set) { return (set % 64) == 1; }
// ---- END DO NOT EDIT ----

// TODO 1 Task 2: one RRPV per block, at index set * NUM_WAY + way
std::map<CACHE*, std::vector<uint32_t>> rrpv;

// called once before the simulation starts
void CACHE::initialize_replacement()
{
  // TODO 2 Task 2: every block starts at the distant end
  rrpv[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY, maxRRPV);
}

// called when the set is full: return the way to evict
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  // TODO 3 Task 2: evict the first block at maxRRPV; if there is none, age every block and look again
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

  // TODO 4 Task 2: hit promotion and the writeback rule
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

  // TODO 5 Task 2 (DRRIP): pick this set's insertion policy, and train PSEL on a leader miss
  bool use_brrip;
  if (srrip_leader(set)) {
    use_brrip = false;
    if (PSEL < PSEL_MAX) PSEL++;       // SRRIP missed here -> lean towards BRRIP
  } else if (brrip_leader(set)) {
    use_brrip = true;
    if (PSEL > 0) PSEL--;              // BRRIP missed here -> lean towards SRRIP
  } else {
    use_brrip = (PSEL > PSEL_MAX / 2); // follower: copy whichever policy is winning
  }

  // TODO 6 Task 2 (DRRIP): insert with the chosen policy
  if (!use_brrip) {
    r = maxRRPV - 1;                   // SRRIP: one step from eviction
  } else {
    if (brrip_fills == 0)
      r = maxRRPV - 1;                 // BRRIP: 1 in BRRIP_INTERVAL near the front
    else
      r = maxRRPV;                     // the rest at the distant end
    brrip_fills = (brrip_fills + 1) % BRRIP_INTERVAL;
  }
}

void CACHE::replacement_final_stats() {}

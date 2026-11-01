.SUFFIXES:

# make taskN [trace=soplex] [long=1]
#   copies Champsim/ to .taskN_champsim/, puts your files for that task in it, builds it with
#   srrip_llc at the LLC and runs it on one trace. Tasks build on each other:
#     task1: task1/srrip_llc.cc
#     task2: task1/srrip_llc.cc, task2/sampler.h, task2/cache.cc
#     task3: task1/srrip_llc.cc, task2/sampler.h, task3/cache.cc
#     task4: task4/srrip_llc.cc, task2/sampler.h, task3/cache.cc
# make task5 COUNTER_BITS=3 THRESHOLD=20 [trace=soplex] [long=1]
#   your Task 4 code (the task4 files) with other predictor settings
# make lru            the given ChampSim with lru at the LLC (baseline)
# make quickcheck     sanity check: every task, 5M + 10M on the four traces, against taskN/expected_output.txt
# make longcheck      grading check: every task, 20M + 25M, against taskN/expected_output_long.txt
# make quickcheck-taskN / longcheck-taskN   the same for one task
# make diff-task3     your task3/cache.cc against the given Champsim/src/cache.cc

CHAMPSIM  := Champsim
# Traces: $CS231_TRACE_DIR if set, else /opt/CS231_Traces (lab machines).
# A trace is found by name: trace=soplex picks the first file matching *soplex*.xz.
TRACE_DIR ?= $(or $(CS231_TRACE_DIR),/opt/CS231_Traces)
trace_file = $(or $(firstword $(wildcard $(TRACE_DIR)/*$1*.xz)),$(error no trace matching *$1*.xz in $(TRACE_DIR)))
TRACES    := soplex bwaves mcf gcc
trace     ?= soplex

# Long runs give the numbers in the PDF and are what longcheck (grading) compares.
LONG_WARMUP  := 20000000
LONG_SIM     := 25000000
QUICK_WARMUP := 5000000
QUICK_SIM    := 10000000

# make taskN: a quick run for build and sanity checks; long=1 for a long run.
ifdef long
WARMUP := $(LONG_WARMUP)
SIM    := $(LONG_SIM)
else
WARMUP := $(QUICK_WARMUP)
SIM    := $(QUICK_SIM)
endif

TASKS := task1 task2 task3 task4

# solution_makefile sets this to _solution and builds the *_solution files instead.
SUFFIX ?=

# The files each task builds with: <srrip_llc.cc> <sampler.h> <cache.cc>
files_task1 := task1/srrip_llc$(SUFFIX).cc $(CHAMPSIM)/inc/sampler.h $(CHAMPSIM)/src/cache.cc
files_task2 := task1/srrip_llc$(SUFFIX).cc task2/sampler$(SUFFIX).h task2/cache$(SUFFIX).cc
files_task3 := task1/srrip_llc$(SUFFIX).cc task2/sampler$(SUFFIX).h task3/cache$(SUFFIX).cc
files_task4 := task4/srrip_llc$(SUFFIX).cc task2/sampler$(SUFFIX).h task3/cache$(SUFFIX).cc

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

STATS := '^CPU 0 cumulative IPC|^LLC (TOTAL|LOAD|RFO|WRITEBACK) |^LLC (EVICTIONS|DEAD ON ARRIVAL|PREDICTED DEAD):'

# results <simulated instructions>: reads ChampSim's output, prints
# "IPC LLC-MPKI DEAD-ON-ARRIVAL PREDICTED-DEAD". LLC MPKI counts demand misses only:
# (LOAD + RFO misses) / (simulated instructions / 1000).
results = awk -v n=$1 '/^CPU 0 cumulative IPC/ {i = $$5} /^LLC LOAD/ {ld = $$NF} /^LLC RFO/ {r = $$NF} \
	/^LLC DEAD ON ARRIVAL:/ {d = $$NF} /^LLC PREDICTED DEAD:/ {p = $$NF} \
	END {printf "%s %.4f %s %s\n", i, (ld + r) / (n / 1000), d, p}'

CHECKS := $(foreach k,quickcheck longcheck,$(addprefix $k-,$(TASKS)))
.PHONY: default $(TASKS) task5 lru quickcheck longcheck clean diff-task3 $(CHECKS)

default:
	@printf "Usage: make [task1|task2|task3|task4|task5|lru|quickcheck|longcheck|quickcheck-taskN|longcheck-taskN|diff-task3] [trace=soplex|bwaves|mcf|gcc] [long=1]\n"

# build <dir> <LLC policy> <srrip_llc.cc> <sampler.h> <cache.cc> [<CPPFLAGS>]: fresh copy of
# Champsim/ in <dir> with the three files in place, built with <LLC policy> at the LLC
define build
	@rm -rf $1 && cp -r $(CHAMPSIM) $1 && rm -rf $1/bin $1/obj
	@mkdir -p $1/replacement/srrip_llc && cp $3 $1/replacement/srrip_llc/srrip_llc.cc
	@cp $4 $1/inc/sampler.h && cp $5 $1/src/cache.cc
	@python3 -c "import json; c = json.load(open('$1/champsim_config.json')); \
		c['executable_name'] = 'bin/champsim'; c['LLC']['replacement'] = '$2'; c['CPPFLAGS'] = '$6'; \
		json.dump(c, open('$1/config.json', 'w'), indent=4)"
	@printf "Building $1/bin/champsim from $3 $4 $5\n" | fold -s -w 72
	@cd $1 && ./config.sh config.json > /dev/null 2>&1 && ($(MAKE) --no-print-directory -s -j4 > build.log 2>&1 || (grep -A3 -E 'error|Error' build.log; exit 1))
endef

build_task = $(call build,.$1_champsim,srrip_llc,$(word 1,$(files_$1)),$(word 2,$(files_$1)),$(word 3,$(files_$1)))

# run_one <binary>: run on one trace, print the key rows plus the LLC MPKI line
define run_one
	@printf "$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) $(call trace_file,$(trace))\n"
	@$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) --hide_heartbeat $(call trace_file,$(trace)) \
		| awk -v n=$(SIM) '/$(subst ',,$(STATS))/ {print} /^LLC LOAD/ {ld = $$NF} /^LLC RFO/ {r = $$NF} \
			END {printf "LLC MPKI (LOAD+RFO): %.4f\n", (ld + r) / (n / 1000)}'
endef

$(TASKS):
	$(call build_task,$@)
	$(call run_one,.$@_champsim/bin/champsim)

build_lru = $(call build,.lru_champsim,lru,$(CHAMPSIM)/replacement/lru/lru.cc,$(CHAMPSIM)/inc/sampler.h,$(CHAMPSIM)/src/cache.cc)

# Task 5: predictor counter width and threshold (defaults: the Task 2-4 values)
COUNTER_BITS ?= 2
THRESHOLD    ?= 8

task5:
	$(call build,.task5_champsim,srrip_llc,$(word 1,$(files_task4)),$(word 2,$(files_task4)),$(word 3,$(files_task4)),-DDBP_COUNTER_BITS=$(COUNTER_BITS) -DDBP_THRESHOLD=$(THRESHOLD))
	@printf "COUNTER_BITS=$(COUNTER_BITS) THRESHOLD=$(THRESHOLD)\n"
	$(call run_one,.task5_champsim/bin/champsim)

lru:
	$(build_lru)
	$(call run_one,.lru_champsim/bin/champsim)

diff-task3:
	@diff -u $(CHAMPSIM)/src/cache.cc task3/cache.cc || true

# Each task: build once, run the four traces in parallel, compare with the reference.
# Tasks run one after another; do not use make -j.
quickcheck: $(addprefix quickcheck-,$(TASKS))
longcheck: $(addprefix longcheck-,$(TASKS))

# check_runs <task> <warmup> <sim> <reference file>: run the four traces in parallel and compare
# IPC, LLC MPKI and the two dead block percentages with the reference file. ChampSim is
# deterministic, so a correct solution gives exactly the reference numbers.
define check_runs
	@for tr in $(TRACES); do \
		( got=$$(.$1_champsim/bin/champsim --warmup_instructions $2 --simulation_instructions $3 \
			--hide_heartbeat $$(ls $(TRACE_DIR)/*$$tr*.xz) | $(call results,$3)); \
		  want=$$(awk -v tr=$$tr '$$1 == tr {print $$2, $$3, $$4, $$5}' $4 2>/dev/null); \
		  set -- $$got; \
		  if [ -n "$$want" ] && [ "$$got" = "$$want" ]; \
		  then printf "[%s] %-7s | "$(GREEN)"PASS"$(RESET)"  IPC %s, LLC MPKI %s, dead on arrival %s, predicted dead %s\n" $1 $$tr $$1 $$2 $$3 $$4; \
		  else printf "[%s] %-7s | "$(RED)"FAIL"$(RESET)" (differs from the reference)\n    got:      %s\n    expected: %s\n" $1 $$tr "$$got" "$$want"; fi ) & \
	done; wait
endef

$(CHECKS): %:
	@: $(foreach tr,$(TRACES),$(call trace_file,$(tr)))
	$(call build_task,$(lastword $(subst -, ,$@)))
	$(call check_runs,$(lastword $(subst -, ,$@)),$($(if $(filter long%,$@),LONG,QUICK)_WARMUP),$($(if $(filter long%,$@),LONG,QUICK)_SIM),$(lastword $(subst -, ,$@))/expected_output$(if $(filter long%,$@),_long).txt)

clean:
	@rm -rfv $(foreach t,$(TASKS) task5 lru,.$t_champsim)

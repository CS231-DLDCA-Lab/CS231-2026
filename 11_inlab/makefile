.SUFFIXES:

# make task1              the native perf task (convolution); delegates to task1/makefile
# make task2 [trace=soplex] [long=1]
#   copies task2/drrip.cc into Champsim/replacement/drrip/, builds Champsim/bin/drrip with
#   that policy at the LLC, and runs it on one trace.
# make task3 [trace=soplex] [long=1]
#   copies Champsim/ to .task3_champsim/, applies task3/task3.patch, puts your task3/cache.cc
#   in place of src/cache.cc, builds and runs it on one trace.
# make lru            ChampSim's own lru at the LLC, unmodified cache.cc (baseline for task2)
# make check          runs every task and compares with the reference

CHAMPSIM  := Champsim
# Traces: $CS231_TRACE_DIR if set, else /opt/CS231_Traces (lab machines).
# A trace is found by name: trace=soplex picks the first file matching *soplex*.xz.
TRACE_DIR ?= $(or $(CS231_TRACE_DIR),/opt/CS231_Traces)
trace_file = $(or $(firstword $(wildcard $(TRACE_DIR)/*$1*.xz)),$(error no trace matching *$1*.xz in $(TRACE_DIR)))
TRACES    := soplex bwaves mcf gcc
trace     ?= soplex

# Quick run for build and sanity checks. long=1 gives the numbers quoted in the PDF.
ifdef long
WARMUP := 20000000
SIM    := 25000000
else
WARMUP := 1000000
SIM    := 10000000
endif

# Length of one run in `make check`.
CHECK_WARMUP := 1000000
CHECK_SIM    := 5000000

# A policy task is any folder (other than task3) with one policy source. The policy name is
# the file name; it is also the folder under Champsim/replacement/ and the binary in bin/.
policy = $(basename $(notdir $(filter-out %_solution.cc,$(wildcard $1/*.cc))))

POLICY_TASKS := $(patsubst %/,%,$(sort $(filter-out task3/,$(dir $(wildcard */*.cc)))))
TASKS        := $(POLICY_TASKS) task3

# Task 3 edits ChampSim itself, so it is built in a private copy that is made
# again from Champsim/ on every build. The other tasks never see these edits.
T3 := .task3_champsim

# solution_makefile sets this to _solution and builds the *_solution files instead.
SUFFIX ?=

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

STATS := '^CPU 0 cumulative IPC|^cpu0_L2C (TOTAL|LOAD|RFO|WRITEBACK) |^LLC (TOTAL|LOAD|RFO|WRITEBACK) |^L2C LINES ALSO IN LLC'

# ipc_mpki <simulated instructions>: reads ChampSim's output, prints "IPC L2C-MPKI LLC-MPKI".
# MPKI = TOTAL misses of that cache / (simulated instructions / 1000), with the count we asked for.
ipc_mpki = awk -v n=$1 '/^CPU 0 cumulative IPC/ {i = $$5} /^cpu0_L2C TOTAL/ {m = $$NF} /^LLC TOTAL/ {l = $$NF} \
	END {printf "%s %.4f %.4f\n", i, m / (n / 1000), l / (n / 1000)}'

.PHONY: default $(TASKS) task1 lru check clean $(addprefix check-,$(TASKS)) check-task1

default:
	@printf "Usage: make [task1|%s|lru|check] [trace=soplex|bwaves|mcf|gcc] [long=1]\n" "$$(echo $(TASKS) | tr ' ' '|')"

# Task 1 is the native perf task: its own makefile in task1/.
task1:
	@$(MAKE) -C task1 all
check-task1:
	@$(MAKE) -C task1 check

# build <policy> <source .cc>: install the source as that policy, set it at the LLC, compile
define build
	@mkdir -p $(CHAMPSIM)/replacement/$1
	@if [ -n "$2" ]; then cp $2 $(CHAMPSIM)/replacement/$1/$1.cc; fi
	@python3 -c "import json; c = json.load(open('$(CHAMPSIM)/champsim_config.json')); \
		c['executable_name'] = 'bin/$1'; c['LLC']['replacement'] = '$1'; \
		json.dump(c, open('$(CHAMPSIM)/$1.json', 'w'), indent=4)"
	@printf "Building $(CHAMPSIM)/bin/$1 (LLC replacement = $1)\n"
	@cd $(CHAMPSIM) && ./config.sh $1.json > /dev/null 2>&1 && $(MAKE) --no-print-directory -s > /dev/null
endef

# build_task3: fresh copy of Champsim/, Task 3 patch applied, then your task3/cache.cc
# in place of src/cache.cc; default config (lru everywhere)
define build_task3
	@rm -rf $(T3) && cp -r $(CHAMPSIM) $(T3) && rm -rf $(T3)/bin $(T3)/obj
	@find $(T3) \( -name '*.o' -o -name '*.d' \) -delete
	@task3/apply_patch.sh $(T3) > /dev/null
	@cp task3/cache$(SUFFIX).cc $(T3)/src/cache.cc
	@printf "Building $(T3)/bin/champsim with task3.patch and task3/cache$(SUFFIX).cc\n"
	@cd $(T3) && ./config.sh champsim_config.json > /dev/null 2>&1 && $(MAKE) --no-print-directory -s -j4 > /dev/null
endef

# run <binary> <trace> <warmup> <sim> <grep pattern>
define run
	@printf "$1 --warmup_instructions $3 --simulation_instructions $4 $(call trace_file,$2)\n"
	@$1 --warmup_instructions $3 --simulation_instructions $4 --hide_heartbeat $(call trace_file,$2) | grep -E $5
endef

# run_policy <binary>: run on one trace, print the key rows plus computed L2C and LLC MPKI lines
define run_policy
	@printf "$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) $(call trace_file,$(trace))\n"
	@$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) --hide_heartbeat $(call trace_file,$(trace)) \
		| awk -v n=$(SIM) '/$(subst ',,$(STATS))/ {print} /^cpu0_L2C TOTAL/ {m = $$NF} /^LLC TOTAL/ {l = $$NF} \
			END {printf "cpu0_L2C MPKI: %.4f\nLLC MPKI: %.4f\n", m / (n / 1000), l / (n / 1000)}'
endef

task3:
	$(build_task3)
	$(call run_policy,$(T3)/bin/champsim)

$(POLICY_TASKS):
	$(call build,$(call policy,$@),$@/$(call policy,$@)$(SUFFIX).cc)
	$(call run_policy,$(CHAMPSIM)/bin/$(call policy,$@))

lru:
	$(call build,lru,)
	$(call run_policy,$(CHAMPSIM)/bin/lru)

# Each task: build once, run the four traces in parallel, compare with the reference.
# Tasks run one after another (they share Champsim/Makefile); do not use make -j.
check: check-task1 $(addprefix check-,$(TASKS))

# IPC and L2C MPKI must equal the reference exactly: ChampSim is deterministic, so a correct
# policy gives the same numbers as ours. TOL is the allowed fraction (0 = exact).
TOL := 0

# Traces used by `make check`, per task (all four by default).
# `make check check_traces="..."` overrides the list for every task.
traces_for = $(or $(check_traces),$(check_traces_$1),$(TRACES))

# pass_fail <label> <trace> <got> <want>: exact match
pass_fail = if [ -n "$3" ] && [ "$3" = "$4" ]; then printf "[%s] %-7s | "$(GREEN)"PASS"$(RESET)"\n" "$1" $2; \
	else printf "[%s] %-7s | "$(RED)"FAIL"$(RESET)"\n    got:      %s\n    expected: %s\n" "$1" $2 "$3" "$4"; fi

# within <got> <want>: true if got is within TOL of want
within = awk -v g="$1" -v w="$2" -v t=$(TOL) 'BEGIN { d = g - w; if (d < 0) d = -d; exit !(g != "" && w != "" && d <= t * w) }'

# result_check <task> <trace> "<ipc> <l2c mpki> <llc mpki>" "<reference, same order>": all three within TOL
result_check = set -- $3 $4; \
	if $(call within,$$1,$$4) && $(call within,$$2,$$5) && $(call within,$$3,$$6); \
	then printf "[%s] %-7s | "$(GREEN)"PASS"$(RESET)"  IPC %s, L2C MPKI %s, LLC MPKI %s\n" "$1" $2 "$$1" "$$2" "$$3"; \
	else printf "[%s] %-7s | "$(RED)"FAIL"$(RESET)" (differs from the reference)\n    got:      IPC %s, L2C MPKI %s, LLC MPKI %s\n    expected: IPC %s, L2C MPKI %s, LLC MPKI %s\n" \
		"$1" $2 "$$1" "$$2" "$$3" "$$4" "$$5" "$$6"; fi

# need_traces <task>: stop with a clear error if one of its traces is missing
need_traces = @: $(foreach tr,$(call traces_for,$1),$(call trace_file,$(tr)))

# check_runs <task> <binary>: run the task's check traces in parallel and compare
# IPC, L2C MPKI and LLC MPKI with <task>/expected_output.txt (within TOL)
define check_runs
	@for tr in $(call traces_for,$1); do \
		( out=$$($2 --warmup_instructions $(CHECK_WARMUP) --simulation_instructions $(CHECK_SIM) \
			--hide_heartbeat $$(ls $(TRACE_DIR)/*$$tr*.xz | head -1)); \
		  got=$$(echo "$$out" | $(call ipc_mpki,$(CHECK_SIM))); \
		  want=$$(awk -v tr=$$tr '$$1 == tr {print $$2, $$3, $$4}' $1/expected_output.txt 2>/dev/null); \
		  res=$$($(call result_check,$1,$$tr,$$got,$$want); \
		         echo "$$out" | sed -n 's/^L2C LINES ALSO IN LLC/    L2C lines also in LLC/p'); \
		  echo "$$res" ) & \
	done; wait
endef

$(addprefix check-,$(POLICY_TASKS)): check-%:
	$(call need_traces,$*)
	$(call build,$(call policy,$*),$*/$(call policy,$*)$(SUFFIX).cc)
	$(call check_runs,$*,$(CHAMPSIM)/bin/$(call policy,$*))

check-task3:
	$(call need_traces,task3)
	$(build_task3)
	$(call check_runs,task3,$(T3)/bin/champsim)

clean:
	@rm -rfv $(foreach t,$(POLICY_TASKS),$(foreach p,$(call policy,$t),$(CHAMPSIM)/replacement/$p $(CHAMPSIM)/$p.json)) \
		$(CHAMPSIM)/lru.json $(CHAMPSIM)/bin $(CHAMPSIM)/obj $(T3)
	@find $(CHAMPSIM) \( -name '*.o' -o -name '*.d' \) -delete -print
	@$(MAKE) -C task1 clean

.SUFFIXES:

# Compiler: the first of g++-13, g++-12, g++-11, g++ that is installed.
CXX_CANDIDATES := g++-13 g++-12 g++-11 g++
CXX := $(firstword $(foreach c,$(CXX_CANDIDATES),$(if $(shell command -v $(c) 2>/dev/null),$(c))))

ifeq ($(CXX),)
$(error No g++ found (tried: $(CXX_CANDIDATES)))
endif

CXXFLAGS := -g -O2 -std=c++17 -Wall
LDFLAGS  := -no-pie -z noexecstack

SOL ?=

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

.PHONY: default clean check

default:
	@echo "Usage: make check | make task1a | make task1b | make task1-check | make task2 | make task2-check | make task3 | make task3-check | make clean"

# Runs every check, then adds up the "taskX: s/t marks" lines into a grand total.
check:
	@mkdir -p .tmp; $(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-check task2-check task3-check 2>&1 | tee .tmp/check.log; \
	awk -F'[ /]' '/^task[0-9a-z]+: [0-9]+\/[0-9]+ marks/ {s += $$2; t += $$3} END {printf "==== grand total: %d/%d marks ====\n", s, t}' .tmp/check.log

%.o: %.cpp
	@$(CXX) $(CXXFLAGS) -c -o $@ $<

# task3/cache.a is provided (the simulated cache); clean must never remove it.
clean:
	@rm -f *.out task*/*.o
	@find . -path './task*/tests/*' -name .got -delete
	@rm -rf .tmp
	@rm -rf .task2_champsim
	@rm -rf .champsim_srrip .champsim_ghost_rrip .champsim_lru

# ==== TASK 1: srrip.cc (part a) and ghost_rrip.cc (part b) as the LLC replacement policy in ChampSim ====
# make task1a [trace=soplex] [long=1]  install task1/srrip.cc, build .champsim_srrip/bin/srrip, run one trace
# make task1b [trace=soplex] [long=1]  install task1/ghost_rrip.cc, build .champsim_ghost_rrip/bin/ghost_rrip, run one trace
# make lru [trace=soplex] [long=1]     ChampSim's own lru at the LLC, for comparison (whole ChampSim output)
# make task1-check                     run soplex and mcf, compare IPC and LLC MPKI with the reference
# make task1a-check / task1b-check     the same for one part only
#
# Traces: $CS231_TRACE_DIR if set, else /opt/CS231_Traces (lab machines).
# A trace is found by name: trace=soplex picks the first file matching *soplex*.xz.
TRACE_DIR ?= $(or $(CS231_TRACE_DIR),/opt/CS231_Traces)
trace_file = $(or $(firstword $(wildcard $(TRACE_DIR)/*$1*.xz)),$(error no trace matching *$1*.xz in $(TRACE_DIR)))
trace     ?= soplex

# Default run: the same length as task1-check, so the numbers match the table in the PDF.
# long=1 gives a longer run, to see the trend.
ifdef long
WARMUP := 20000000
SIM    := 25000000
else
WARMUP := 1000000
SIM    := 5000000
endif

# Length of one run in `make task1-check` and `make task2-check`.
CHECK_WARMUP := 1000000
CHECK_SIM    := 5000000

# One TCG per part and trace, part:trace:marks. bwaves and gcc are left out: every LLC policy gives them the same numbers.
# Part (a) runs task1/srrip.cc, part (b) runs task1/ghost_rrip.cc.
TASK1_TCGS := a:soplex:2 a:mcf:2 b:soplex:4 b:mcf:4
# parts=a or parts=b checks one part only (task1a-check, task1b-check)
parts ?= a b
TASK1_RUN := $(filter $(addsuffix :%,$(parts)),$(TASK1_TCGS))

# Champsim/ stays the original ChampSim: every policy is built in its own copy, .champsim_<policy>
# (made once, kept for incremental builds; make clean removes it). So task1a, task1b and lru can run at the same time.
T1 = .champsim_$1

# build1 <policy> <source .cc or empty>: install the source as that policy in $(T1), set it at the LLC, compile
define build1
	@[ -d $(T1) ] || cp -r Champsim $(T1)
	@mkdir -p $(T1)/replacement/$1
	@if [ -n "$2" ]; then cp $2 $(T1)/replacement/$1/$1.cc; fi
	@python3 -c "import json; c = json.load(open('$(T1)/champsim_config.json')); \
		c['executable_name'] = 'bin/$1'; c['LLC']['replacement'] = '$1'; \
		json.dump(c, open('$(T1)/$1.json', 'w'), indent=4)"
	@printf "Building $(T1)/bin/$1 (LLC replacement = $1)\n"
	@mkdir -p .tmp; cd $(T1) && { ./config.sh $1.json && $(MAKE) --no-print-directory -s -j4; } > ../.tmp/build_$1.log 2>&1 \
		|| { cat ../.tmp/build_$1.log; printf $(RED)"build failed"$(RESET)" (the compiler output is above)\n"; exit 1; }
endef

# ipc_mpki <simulated instructions>: reads ChampSim's output, prints "IPC LLC-MPKI"
ipc_mpki = awk -v n=$1 '/^CPU 0 cumulative IPC/ {i = $$5} /^LLC TOTAL/ {l = $$NF} END {printf "%s %.4f\n", i, l / (n / 1000)}'

# run1 <binary>: run on $(trace), print IPC, the LLC rows and the LLC MPKI
define run1
	@printf "$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) $(call trace_file,$(trace))\n"
	@$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) --hide_heartbeat $(call trace_file,$(trace)) \
		| awk -v n=$(SIM) '/^CPU 0 cumulative IPC|^LLC (TOTAL|LOAD|RFO|WRITEBACK) / {print} /^LLC TOTAL/ {l = $$NF} \
			END {printf "LLC MPKI: %.4f\n", l / (n / 1000)}'
endef

# run_full <binary>: run on $(trace), print ChampSim's whole output (every cache level), then the LLC MPKI
define run_full
	@printf "$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) $(call trace_file,$(trace))\n"
	@$1 --warmup_instructions $(WARMUP) --simulation_instructions $(SIM) --hide_heartbeat $(call trace_file,$(trace)) \
		| awk -v n=$(SIM) '{print} /^LLC TOTAL/ {l = $$NF} END {printf "LLC MPKI: %.4f\n", l / (n / 1000)}'
endef

.PHONY: task1a task1b lru task1-check task1a-check task1b-check
task1a:
	$(call build1,srrip,task1/srrip$(SOL).cc)
	$(call run1,.champsim_srrip/bin/srrip)

task1b:
	$(call build1,ghost_rrip,task1/ghost_rrip$(SOL).cc)
	$(call run1,.champsim_ghost_rrip/bin/ghost_rrip)

lru:
	$(call build1,lru,)
	$(call run_full,.champsim_lru/bin/lru)

# Builds .champsim_srrip/bin/srrip (part (a)) and .champsim_ghost_rrip/bin/ghost_rrip (part (b)), only for the parts in $(parts),
# then runs their groups in parallel; .tmp/task1.<part>.<trace> gets "IPC LLC-MPKI", or "BUILD-FAILED" or
# "CRASHED <exit code>". A part that does not build does not stop the other part.
.PHONY: task1-runs task1-build-a task1-build-b
task1-build-a:
	$(call build1,srrip,task1/srrip$(SOL).cc)

task1-build-b:
	$(call build1,ghost_rrip,task1/ghost_rrip$(SOL).cc)

task1-runs:
	@: $(foreach t,$(TASK1_RUN),$(call trace_file,$(word 2,$(subst :, ,$t))))
	@rm -f .champsim_srrip/bin/srrip .champsim_ghost_rrip/bin/ghost_rrip
	-@for p in $(parts); do $(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-build-$$p; done
	@for t in $(TASK1_RUN); do p=$${t%%:*}; r=$${t#*:}; tr=$${r%%:*}; bin=$$([ $$p = a ] && echo .champsim_srrip/bin/srrip || echo .champsim_ghost_rrip/bin/ghost_rrip); \
		out=.tmp/task1.$$p.$$tr; \
		if [ ! -x $$bin ]; then echo BUILD-FAILED > $$out; continue; fi; \
		( $$bin --warmup_instructions $(CHECK_WARMUP) --simulation_instructions $(CHECK_SIM) \
			--hide_heartbeat $$(ls $(TRACE_DIR)/*$$tr*.xz | head -1) > $$out.log 2>&1; rc=$$?; \
		  if [ $$rc -ne 0 ]; then echo "CRASHED $$rc" > $$out; else $(call ipc_mpki,$(CHECK_SIM)) < $$out.log > $$out; fi ) & \
	done; wait

# One group per part and trace: IPC and LLC MPKI must equal task1/expected_output.txt exactly
# (ChampSim is deterministic).
task1a-check:
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-check parts=a

task1b-check:
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-check parts=b

task1-check:
	@echo "---- task1 ----"
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-runs parts="$(parts)"
	@score=0; total=0; g=1; \
	for t in $(TASK1_TCGS); do case " $(TASK1_RUN) " in *" $$t "*) ;; *) g=$$((g + 1)); continue;; esac; p=$${t%%:*}; r=$${t#*:}; tr=$${r%%:*}; m=$${r#*:}; total=$$((total + m)); \
		echo "Group $$g ($$m mark$$([ $$m = 1 ] || echo s)): part ($$p), $$tr, IPC and LLC MPKI"; \
		got=$$(cat .tmp/task1.$$p.$$tr); want=$$(awk -v p=$$p -v tr=$$tr '$$1 == p && $$2 == tr {print $$3, $$4}' task1/expected_output.txt); \
		f=task1/$$([ $$p = a ] && echo srrip || echo ghost_rrip).cc; \
		case "$$got" in \
		BUILD-FAILED) printf "  $$f did not compile (the compiler output is above)\n" ;; \
		CRASHED*) printf "  the simulator crashed (exit code %s): run make task1$$p trace=$$tr to see the error\n" "$${got#CRASHED }" ;; esac; \
		if [ -n "$$got" ] && [ "$$got" = "$$want" ]; then \
			printf "  IPC and LLC MPKI: %s\n"$(GREEN)"Group %s PASS"$(RESET)" -- %s/%s marks\n\n" "$$got" $$g $$m $$m; score=$$((score + m)); \
		else printf "  got:      %s\n  expected: %s\n"$(RED)"Group %s FAIL"$(RESET)" -- 0/%s marks\n\n" "$$got" "$$want" $$g $$m; fi; \
		g=$$((g + 1)); \
	done; \
	echo "task1: $$score/$$total marks"; echo

# ==== TASK 2: inclusive LLC, in copies of cache.h, cache.cc and main.cc ====
# make task2 [trace=soplex] [long=1]  build a private ChampSim with task2/cache.h, cache.cc, main.cc, run one trace
# make task2-check                    run soplex and mcf: (a) IPC and LLC MPKI, (c) the BACKINVAL MISS counts
#
# Task 2 edits ChampSim itself, so it is built in a private copy, made again from Champsim/ on every
# build. The other tasks never see these edits.
T2 := .task2_champsim
# One TCG per trace and part, trace:marks.
TASK2A_TCGS := soplex:6 mcf:6
TASK2C_TCGS := soplex:3 mcf:3
# Part (a) is graded in two tiers per trace, on the larger gap of IPC and LLC MPKI from the reference:
#   within TASK2_TOL1 percent: half the marks; within TASK2_TOL2 percent: all the marks.
TASK2_TOL1 := 0.01
TASK2_TOL2 := 0.001

define build_task2
	@rm -rf $(T2) && cp -r Champsim $(T2)
	@cp task2/cache.h $(T2)/inc/cache.h
	@cp task2/cache$(SOL).cc $(T2)/src/cache.cc
	@cp task2/main.cc $(T2)/src/main.cc
	@printf "Building $(T2)/bin/champsim with task2/cache.h, cache$(SOL).cc, main.cc\n"
	@mkdir -p .tmp; cd $(T2) && { ./config.sh champsim_config.json && $(MAKE) --no-print-directory -s -j4; } > ../.tmp/build_task2.log 2>&1 \
		|| { cat ../.tmp/build_task2.log; printf $(RED)"build failed"$(RESET)" (the compiler output is above)\n"; exit 1; }
endef

.PHONY: task2 task2-check
task2:
	$(build_task2)
	$(call run_full,$(T2)/bin/champsim)

# Runs the traces in parallel, then one TCG per trace and part:
#   (a) IPC and LLC MPKI must equal task2/expected_output.txt
#   (c) the BACKINVAL MISS counts of L2C, L1D, L1I against task2/expected_backinval.txt, 1 mark per cache
# (b) and (d) are written answers in task2/answer.txt, graded by hand.
task2-check:
	@echo "---- task2 ----"
	@: $(foreach t,$(TASK2A_TCGS) $(TASK2C_TCGS),$(call trace_file,$(firstword $(subst :, ,$t))))
	$(build_task2)
	@for tr in $(sort $(foreach t,$(TASK2A_TCGS) $(TASK2C_TCGS),$(firstword $(subst :, ,$t)))); do \
		( $(T2)/bin/champsim --warmup_instructions $(CHECK_WARMUP) --simulation_instructions $(CHECK_SIM) --hide_heartbeat \
			$$(ls $(TRACE_DIR)/*$$tr*.xz | head -1) > .tmp/task2.$$tr.out; \
		  $(call ipc_mpki,$(CHECK_SIM)) < .tmp/task2.$$tr.out > .tmp/task2.$$tr; \
		  awk '/BACKINVAL MISS/ {print $$1, $$4}' .tmp/task2.$$tr.out > .tmp/task2.$$tr.bi ) & \
	done; wait; \
	score=0; total=0; g=1; \
	for t in $(TASK2A_TCGS); do tr=$${t%%:*}; m=$${t#*:}; total=$$((total + m)); \
		echo "TCG $$g ($$m mark$$([ $$m = 1 ] || echo s)): part (a), $$tr, IPC and LLC MPKI within $(TASK2_TOL1)% ($$((m / 2))) and $(TASK2_TOL2)% ($$((m - m / 2)))"; \
		got=$$(cat .tmp/task2.$$tr); want=$$(awk -v tr=$$tr '$$1 == tr {print $$2, $$3}' task2/expected_output.txt); \
		grep -q '^CPU 0 cumulative IPC' .tmp/task2.$$tr.out || [ ! -x $(T2)/bin/champsim ] || \
			printf "  the simulator crashed on %s: run make task2 trace=%s to see the error\n" $$tr $$tr; \
		set -- $$(echo "$$got $$want" | awk -v m=$$m -v t1=$(TASK2_TOL1) -v t2=$(TASK2_TOL2) \
			'NF == 4 {ok = 1; for (i = 1; i <= 2; i++) {d = ($$i - $$(i + 2)) / $$(i + 2) * 100; if (d < 0) d = -d; if (d > w) w = d}} \
			END {if (!ok) {print 0, "-"; exit} printf "%d %.4f%%\n", (w <= t2) ? m : (w <= t1) ? int(m / 2) : 0, w}'); \
		e=$$1; printf "  got:      %s\n  expected: %s\n  largest gap: %s\n" "$$got" "$$want" "$$2"; \
		if [ $$e -eq $$m ]; then printf $(GREEN)"TCG %s PASS"$(RESET) $$g; elif [ $$e -gt 0 ]; then printf "TCG %s PARTIAL" $$g; \
		else printf $(RED)"TCG %s FAIL"$(RESET) $$g; fi; printf " -- %s/%s marks\n\n" $$e $$m; score=$$((score + e)); \
		g=$$((g + 1)); \
	done; \
	g=$$((g + 1)); \
	for t in $(TASK2C_TCGS); do tr=$${t%%:*}; m=$${t#*:}; total=$$((total + m)); \
		echo "TCG $$g ($$m mark$$([ $$m = 1 ] || echo s)): part (c), $$tr, BACKINVAL MISS of L2C, L1D, L1I ($$((m / 3)) per cache)"; \
		got=$$(tr '\n' ' ' < .tmp/task2.$$tr.bi); want=$$(awk -v tr=$$tr '$$1 == tr {print $$2, $$3}' task2/expected_backinval.txt | tr '\n' ' '); \
		e=$$(awk -v tr=$$tr -v m=$$m 'FNR == NR {if ($$1 == tr) w[$$2] = $$3; next} ($$1 in w) && !seen[$$1]++ && $$2 == w[$$1] {k++} \
			END {print int(k * m / 3)}' task2/expected_backinval.txt .tmp/task2.$$tr.bi); \
		if [ $$e -eq $$m ]; then printf "  %s\n"$(GREEN)"TCG %s PASS"$(RESET)" -- %s/%s marks\n\n" "$$got" $$g $$m $$m; \
		else printf "  got:      %s\n  expected: %s\n" "$$got" "$$want"; \
			if [ $$e -gt 0 ]; then printf "TCG %s PARTIAL" $$g; else printf $(RED)"TCG %s FAIL"$(RESET) $$g; fi; \
			printf " -- %s/%s marks\n\n" $$e $$m; fi; \
		score=$$((score + e)); \
		g=$$((g + 1)); \
	done; \
	echo "Parts (b) and (d) are graded by hand from task2/answer.txt."; \
	echo "task2: $$score/$$total marks"; echo

# ==== TASK 3: cache_info.cpp, run against the simulated caches in task3/cache.a ====
.PHONY: task3 task3-check task3b-check task3.out

task3.out: task3/main.o task3/cache_info$(SOL).o task3/cache.a
	@$(CXX) $(LDFLAGS) -o $@ $^

task3: task3.out
ifeq ($(strip $(args)),)
	@./task3.out read; true
else
	@echo "./task3.out $(args)"
	@./task3.out $(args); printf "\nReturn Code: %d\n" $$?
endif

# Part B: tests in task3/tests/b. Part A is graded after submission, against the cache of your roll number.
task3b-check: task3.out
	@echo "---- task3 part (b) ----"
	@mkdir -p .tmp; ./check_tests.sh task3b ./task3.out task3/tests/b | tee .tmp/task3b.log; echo
	@echo "Part (c) (4 marks): no remove_from_l1/l2 call in Part (b), and Parts (a) and (b) fully correct"; \
	r=0; for i in task3/tests/b/*_input.txt; do n=$$(timeout 20 ./task3.out count-removes < $$i 2>/dev/null | awk '/^removes/ {print $$2}'); \
		r=$$((r + $${n:-1})); done; \
	echo "  remove_from_l1/l2 calls in the Part (b) tests: $$r"; \
	if [ $$r -eq 0 ] && grep -q '^task3b: 12/12 marks' .tmp/task3b.log; then \
		echo "  on track: Part (c) also needs every Part (a) field right, which is checked after submission"; \
	elif [ $$r -ne 0 ]; then echo "  not earned: Part (b) calls remove_from_l1/l2"; \
	else echo "  not earned yet: Part (b) must pass every test"; fi; echo

# Part A has no local check: it is graded after submission.
task3-check: task3b-check

ifdef tasks

# 1. Run find at build time in Make's environment
FOUND_FILES := $(shell find -L $(addprefix ./,$(filter-out Champsim,$(tasks))) \
	\( -type d \( -iname '*solution*' -o -iname tests -o -iname experiments \) -prune \) -o \
	\( -type f -o -type l \) \
	! \( -iname '*.tex' -o -iname '*.sty' \) \
	! -iname '*solution*' -print )

# 2. Store the script template in a clean multiline variable
define SCRIPT_CONTENT
#!/usr/bin/env bash
set -e

RED=$$(printf '\033[31m')
GREEN=$$(printf '\033[32m')
NC=$$(printf '\033[0m')

read -rp "Enter Student Roll Number: " ROLL_NO
if [ -z "$$ROLL_NO" ]; then
    printf "$${RED}Error: Roll number cannot be empty.$${NC}\n" >&2
    exit 1
fi

# Validate Roll Number against allowed range (901 to 1100)
VALID_PATTERN="^(210050102|2[345]b(090[1-9]|09[1-9][0-9]|10[0-9][0-9]|1100))$$"

if ! echo "$$ROLL_NO" | grep -qE "$$VALID_PATTERN" ; then
    printf "$${RED}Error: Invalid student ID. Please check the ID and try again.$${NC}\n" >&2
    exit 1
fi

mkdir -p "$$ROLL_NO"

FILES=($(FOUND_FILES))

echo "Packaging assignment files..."
for file in "$${FILES[@]}"; do
    if [ -e "$$file" ] || [ -L "$$file" ]; then
        mkdir -p "$$ROLL_NO/$$(dirname "$$file")"
        cp -RP "$$file" "$$ROLL_NO/$$file"
        printf "  $${GREEN}[+] Copied:$${NC} %s\n" "$$file"
    else
        printf "$${RED}Error: Required file or symlink missing: %s$${NC}\n" "$$file" >&2
        rm -rf "$$ROLL_NO"
        exit 1
    fi
done

tar -czf "$${ROLL_NO}.tar.gz" "$$ROLL_NO"
rm -rf "$$ROLL_NO"
printf "$${GREEN}Successfully created $${ROLL_NO}.tar.gz$${NC}\n"
endef

export SCRIPT_CONTENT

.PHONY: build_archive.sh
# 3. Generate target without escaping issues
build_archive.sh:
	@printf '%s\n' "$$SCRIPT_CONTENT" > build_archive.sh
	@chmod +x build_archive.sh

endif

.SUFFIXES:

# Pick the first available compiler: g++-13 > g++-12 > g++-11 > g++
CXX_CANDIDATES := g++-13 g++-12 g++-11 g++
CXX := $(firstword $(foreach c,$(CXX_CANDIDATES),$(if $(shell command -v $(c) 2>/dev/null),$(c))))

ifeq ($(CXX),)
$(error No g++ found (tried: $(CXX_CANDIDATES)))
endif

AS      := nasm
ASFLAGS := -g -f elf64

# SSE needs no flag; AVX intrinsics need -mavx. Lab machines have AVX but not
# AVX2/FMA, so never add -mavx2, -mfma or -march=native.
SIMD     := -mavx
# Optimised, but the compiler must not vectorise loops itself: the speedup from
# SIMD has to come from your intrinsics.
OPT      := -O2 -fno-tree-vectorize
CFLAGS   := -g $(OPT) $(SIMD)
CXXFLAGS := -g $(OPT) -std=c++23 $(SIMD)

# A task with a .c/.cpp file has a C/C++ main and links with g++.
# A pure assembly task provides _start and links with -nostartfiles.
LDFLAGS_ASM := -no-pie -nostartfiles -z noexecstack
LDFLAGS_CXX := -no-pie -z noexecstack

CPU ?= 1

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

# a task is a taskN/ folder with at least one source file; task2 is MIPS64 and runs in EduMIPS64
MIPS_TASKS := task2
# tasks whose -check compares run times instead of diffing tests/ (task3)
TIMED_TASKS := task3
TASKS     = $(filter-out $(MIPS_TASKS),$(patsubst %/,%,$(sort $(dir $(wildcard task*/*.s task*/*.c task*/*.cpp)))))
TASKS_OUT = $(patsubst %,%.out,$(TASKS))
TASKS_CHK = $(patsubst %,%-check,$(filter-out $(TIMED_TASKS),$(TASKS)))

.PHONY: default clean check $(TASKS) $(TASKS_CHK)

default:
	@printf "Usage: make taskN args=\"...\" | echo ... | make taskN | make taskN-check | make check | make clean\n"

$(TASKS): %: %.out
	@echo "taskset -c $(CPU) ./$*.out $(args)"
	@taskset -c $(CPU) ./$*.out $(args); printf "\nReturn Code: %d\n" $$?

# Run the tests of taskN (by testcase group if taskN/tests/groups.txt exists); see check_tests.sh.
$(TASKS_CHK): %-check: %.out
	@./check_tests.sh $* $(CPU)

check: $(TASKS_CHK) task2-check task3-check

# ---- Task 2: MIPS64 programs, run in EduMIPS64 by ./run_edumips.sh ----
# The tests replace the .data section of a program with N elements a[i] = (37*i + 11) % 1000.
SUM2    := task2/sum.s
TESTS2  := 4 8 100 4096
# Cycle budgets for N = 4096 without forwarding: 14, 12 and 11 cycles per iteration of 4 elements, plus 64.
BUDGETS2 := 14400 12352 11328
MARKS2   := 2 3 4

define GEN2
BEGIN {
  printf "        .data\nn:      .word %d                  ; N, the number of elements\n", n
  printf "s:      .space 8                 ; the sum, written by the program\n"
  for (i = 0; i < n; i++) {
    if (i % 16 == 0) printf "%s", (i ? "\n        .word " : "a:      .word ")
    else printf ", "
    printf "%d", (37 * i + 11) % 1000
  }
  printf "\nguard:  .word 1000000, 1000000   ; not part of a: a loop that reads past the end adds these\n\n"
}
endef
define EXPECT2
BEGIN { s = 0; for (i = 0; i < n; i++) s += (37 * i + 11) % 1000; print s }
endef
export GEN2 EXPECT2

# Shell snippet: build .tmp/<program>.<n>.s from the generated data and the .text section of $p.
BUILD2 = mkdir -p .tmp; t=.tmp/$$(basename $$p .s).$$n.s; { awk -v n=$$n "$$GEN2"; sed -n '/^[[:space:]]*\.text/,$$p' $$p; } > $$t

.PHONY: task2 task2-check

# `make task2` prints the sum and the cycle counts of loop.s and sum.s, without forwarding.
task2:
	@printf "%-22s %5s %8s %15s\n" program N s "no forwarding"; \
	for p in task2/loop.s $(SUM2); do for n in 8 4096; do $(BUILD2); \
		a=$$(./run_edumips.sh $$t nofwd); \
		s=$$(echo "$$a" | sed -n 's/^s: //p'); \
		printf "%-22s %5s %8s %15s\n" $$p $$n "$${s:--}" "$$(echo "$$a" | sed -n 's/^cycles: //p' | grep . || echo FAIL)"; \
	done; done; \
	echo "Run make task2-check for testcases for final grading."

# `make task2-check` checks the sum for every N, then the cycle budgets (N = 4096, no forwarding),
# reported by the testcase groups (TCG) of task2.tex: TCG 1 = every N, TCG 2-4 = one budget each.
task2-check:
	@p=$(SUM2); score=0; pass=1; \
	tcg() { if [ -n "$$pass" ]; then printf $(GREEN)"TCG %s PASS"$(RESET)" -- %s/%s marks\n\n" $$1 $$2 $$2; score=$$((score + $$2)); \
		else printf $(RED)"TCG %s FAIL"$(RESET)" -- 0/%s marks\n\n" $$1 $$2; fi; }; \
	echo "TCG 1 (1 mark)"; \
	for n in $(TESTS2); do $(BUILD2); \
		out=$$(./run_edumips.sh $$t nofwd); want=$$(awk -v n=$$n "$$EXPECT2"); \
		got=$$(echo "$$out" | sed -n 's/^s: //p'); \
		if [ -z "$$(echo "$$out" | sed -n 's/^cycles: //p')" ]; then pass=; \
			printf "  "$(RED)"FAIL"$(RESET)" -- %s N=%s (did not load, crashed or did not finish; run: ./run_edumips.sh %s)\n" $$p $$n $$t; \
		elif [ "$$got" = "$$want" ]; then printf "  "$(GREEN)"PASS"$(RESET)" -- %s N=%s\n" $$p $$n; \
		else pass=; printf "  "$(RED)"FAIL"$(RESET)" -- %s N=%s (s is %s, want %s)\n" $$p $$n "$$got" $$want; fi; \
		[ $$n = 4096 ] && { ok=$$([ "$$got" = "$$want" ] && echo 1); cyc=$$(echo "$$out" | sed -n 's/^cycles: //p'); }; \
	done; \
	tcg 1 1; total=1; \
	set -- $(MARKS2); g=2; for b in $(BUDGETS2); do m=$$1; shift; total=$$((total + m)); echo "TCG $$g ($$m marks)"; pass=1; \
		if [ -z "$$ok" ]; then pass=; printf "  "$(RED)"FAIL"$(RESET)" -- %s cycles <= %s (N=4096, no forwarding): the sum is wrong\n" $$p $$b; \
		elif [ $$cyc -le $$b ]; then printf "  "$(GREEN)"PASS"$(RESET)" -- %s cycles %s <= %s (N=4096, no forwarding)\n" $$p $$cyc $$b; \
		else pass=; printf "  "$(RED)"FAIL"$(RESET)" -- %s cycles %s > %s (N=4096, no forwarding)\n" $$p $$cyc $$b; fi; \
		tcg $$g $$m; g=$$((g + 1)); \
	done; \
	echo "task2: $$score/$$total marks"

# ---- Task 3: timing check against the provided task3/reference ----
# task3/reference is this task3 harness built with the reference dist.cpp and the flags above.
# For each kernel, task3/reference runs first and then your task3.out, each as its own process on
# the same core. The kernel must print PASS, and its best time must be at most LIMIT x the best
# time of the same kernel in task3/reference. dist_simd must also contain at least one packed
# float add/sub/mul ((v)addps, (v)subps, (v)mulps): the makefile does not let the compiler
# vectorise by itself, so these come only from intrinsics.
REF3    := task3/reference
LIMITS3 := 2.5 1.3

.PHONY: task3-check
task3-check: task3.out
	@echo "running ./$(REF3) and ./task3.out on core $(CPU), this takes a while ..."; \
	nsimd=$$(objdump -d --no-show-raw-insn task3.out | \
		awk '/<_Z9dist_simdPKfiiPf>:/ {on = 1; next} on && /^$$/ {exit} on' | \
		grep -cE '[[:space:]]v?(add|sub|mul)ps[[:space:]]'); \
	for k in order simd; do \
		ref=$$(timeout 600 taskset -c $(CPU) ./$(REF3) $$k 2>&1); \
		you=$$(timeout 600 taskset -c $(CPU) ./task3.out $$k 2>&1); \
		r=$$(echo "$$ref" | awk -v k=$$k '$$1 == k && $$4 == "PASS" {print $$2}'); \
		y=$$(echo "$$you" | awk -v k=$$k '$$1 == k && $$4 == "PASS" {print $$2}'); \
		if [ -z "$$r" ]; then printf $(RED)"FAIL"$(RESET)" -- task3 %s: ./%s did not run\n" $$k $(REF3); continue; fi; \
		if [ -z "$$y" ]; then why="wrong result, crash or over 600 s; run: make task3 args=$$k"; \
		elif [ $$k = simd ] && [ "$$nsimd" -eq 0 ]; then why="dist_simd has no packed add/sub/mul instructions"; y=; \
		else why=; fi; \
		if [ -z "$$why" ]; then printf $(GREEN)"PASS"$(RESET)" -- task3 %s correct\n" $$k; \
		else printf $(RED)"FAIL"$(RESET)" -- task3 %s correct (%s)\n" $$k "$$why"; fi; \
		for l in $(LIMITS3); do \
			if [ -z "$$y" ]; then printf $(RED)"FAIL"$(RESET)" -- task3 %s time <= %sx reference: needs task3 %s correct\n" $$k $$l $$k; continue; fi; \
			q=$$(awk -v y=$$y -v r=$$r 'BEGIN {printf "%.2f", y / r}'); \
			if awk -v y=$$y -v r=$$r -v l=$$l 'BEGIN {exit !(y <= l * r)}'; then \
				printf $(GREEN)"PASS"$(RESET)" -- task3 %s %s ms = %sx reference %s ms <= %sx\n" $$k $$y $$q $$r $$l; \
			else printf $(RED)"FAIL"$(RESET)" -- task3 %s %s ms = %sx reference %s ms > %sx\n" $$k $$y $$q $$r $$l; fi; \
		done; \
	done; \
	echo "Times on lab machines are indicative. Final grading runs every submission on one machine."

.SECONDEXPANSION:

all_src = $(wildcard $1/*.s $1/*.c $1/*.cpp)
# Student build: every source except *_solution.*
get_src  = $(filter-out %_solution.s %_solution.c %_solution.cpp,$(call all_src,$1))
get_objs = $(addsuffix .o,$(basename $(call get_src,$1)))
has_cxx  = $(filter %.c %.cpp,$(call get_src,$1))

$(TASKS_OUT): %.out: $$(call get_objs,$$*)
	$(if $(call has_cxx,$*),$(CXX) $(LDFLAGS_CXX),$(CC) $(LDFLAGS_ASM)) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Removes only objects built from sources, so a provided .o binary survives.
clean:
	@rm -fv $(TASKS_OUT) $(addsuffix .o,$(basename $(foreach t,$(TASKS),$(call all_src,$t)))) \
		$(patsubst %,%/tests/.got,$(TASKS))
	@rm -rf .tmp

ifdef tasks

# 1. Run find at build time in Make's environment
FOUND_FILES := $(shell find -L $(addprefix ./,$(tasks)) \
	\( -type d \( -iname '*solution*' -o -iname tests -o -iname hidden \) -prune \) -o \
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
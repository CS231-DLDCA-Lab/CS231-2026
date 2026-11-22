.SUFFIXES:

# Compiler: the first of g++-13, g++-12, g++-11, g++ that is installed.
CXX_CANDIDATES := g++-13 g++-12 g++-11 g++
CXX := $(firstword $(foreach c,$(CXX_CANDIDATES),$(if $(shell command -v $(c) 2>/dev/null),$(c))))

ifeq ($(CXX),)
$(error No g++ found (tried: $(CXX_CANDIDATES)))
endif

AS      := nasm
ASFLAGS := -g -f elf64

# Optimised, but no automatic vectorisation. -falign-loops=64 keeps loop timings independent of
# where a loop lands in the binary.
OPT      := -O2 -fno-tree-vectorize -falign-loops=64
CFLAGS   := -g $(OPT)
CXXFLAGS := -g $(OPT) -std=c++17
LDFLAGS  := -no-pie -z noexecstack

CPU ?= 1
SOL ?=

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

.PHONY: default clean check

default:
	@echo "Usage: make check | make taskN-check | make taskN | make clean"

# Runs every check, then adds up the "taskX: s/t marks" lines into a grand total.
check:
	@mkdir -p .tmp; $(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) task1-check task2-check task3-check task4-check 2>&1 | tee .tmp/check.log; \
	awk -F'[ /]' '/^task[0-9a-z]+: [0-9]+\/[0-9]+ marks/ {s += $$2; t += $$3} END {printf "==== grand total: %d/%d marks ====\n", s, t}' .tmp/check.log

%.o: %.s
	@$(AS) $(ASFLAGS) -o $@ $<

%.o: %.c
	@$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	@$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	@rm -f *.out task*/*.o
	@find . -path './task*/tests/*' -name .got -delete
	@rm -rf .tmp

# ==== TASK 1: each part with its own C harness; task1full links all three parts ====
.PHONY: task1a task1b task1c task1full task1-check task1a.out task1b.out task1c.out task1full.out

task1a.out: task1/test_write.o task1/write$(SOL).o
task1b.out: task1/test_dispatch.o task1/dispatch$(SOL).o
task1c.out: task1/test_average.o task1/average$(SOL).o
task1full.out: task1/test_full.o task1/write$(SOL).o task1/dispatch$(SOL).o task1/average$(SOL).o
task1a.out task1b.out task1c.out task1full.out:
	@$(CC) $(LDFLAGS) -o $@ $^

task1a task1b task1c task1full: %: %.out
	@echo "./$*.out"
	@./$*.out; printf "\nReturn Code: %d\n" $$?

# Tests of part P are in task1/tests/P/.
.PHONY: task1a-check task1b-check task1c-check task1full-check
task1a-check task1b-check task1c-check task1full-check: task1%-check: task1%.out
	@echo "---- task1 part ($*) ----"
	@./check_tests.sh task1$* ./task1$*.out task1/tests/$*; echo
task1-check: task1a-check task1b-check task1c-check task1full-check

# ==== TASK 2: binom.s, called through call_binom.s (checks the callee-saved registers) ====
.PHONY: task2 task2-check task2.out

task2.out: task2/test_binom.o task2/call_binom.o task2/binom$(SOL).o
	@$(CC) $(LDFLAGS) -o $@ $^

task2: task2.out
	@echo "./task2.out"
	@./task2.out; printf "\nReturn Code: %d\n" $$?

task2-check: task2.out
	@echo "---- task2 ----"
	@./check_tests.sh task2; echo

# ==== TASK 3: fast.cpp, timed against task3/reference ====
# task3/reference and task3.out run in turn, 3 times each, on core CPU. Each run prints its best
# time; the medians are compared. The kernel must print PASS in every run.
REF3     := task3/reference
# kernel:marks for a correct result:limit/marks,limit/marks,...
TESTS3   := colsum:1:3.0/1 abt:1:3.0/2,1.3/1
.PHONY: task3 task3-check task3.out

task3.out: task3/main.o task3/base.o task3/fast$(SOL).o
	@$(CXX) $(LDFLAGS) -o $@ $^

task3: task3.out
	@echo "taskset -c $(CPU) ./task3.out $(args)"
	@taskset -c $(CPU) ./task3.out $(args); printf "\nReturn Code: %d\n" $$?

task3-check: task3.out
	@echo "---- task3 ----"; echo "running ./$(REF3) and ./task3.out on core $(CPU), this takes a while ..."; \
	score=0; total=0; g=1; \
	for t in $(TESTS3); do k=$${t%%:*}; rest=$${t#*:}; mc=$${rest%%:*}; limits=$${rest#*:}; \
		ms() { timeout 600 taskset -c $(CPU) $$1 $$k 2>&1 | awk -v k=$$k '$$1 == k && $$4 == "PASS" {print $$2}'; }; \
		med() { echo $$* | tr ' ' '\n' | sort -n | awk '{v[NR] = $$1} END {if (NR) print v[int((NR + 1) / 2)]}'; }; \
		rs=; ys=; for run in 1 2 3; do \
			ri=$$(ms ./$(REF3)); yi=$$(ms ./task3.out); rs="$$rs $$ri"; ys="$$ys $$yi"; [ -n "$$yi" ] || { ys=; break; }; \
		done; \
		r=$$(med $$rs); y=$$(med $$ys); \
		if [ -z "$$r" ]; then printf $(RED)"FAIL"$(RESET)" -- task3 %s: ./%s did not run\n" $$k $(REF3); continue; fi; \
		cg=$$g; total=$$((total + mc)); echo "TCG $$g ($$mc mark$$([ $$mc = 1 ] || echo s)): $$k correct"; \
		if [ -n "$$y" ]; then printf $(GREEN)"TCG %s PASS"$(RESET)" -- %s/%s marks\n\n" $$g $$mc $$mc; score=$$((score + mc)); \
		else printf "  wrong result, crash or over 600 s; run: make task3 args=%s\n"$(RED)"TCG %s FAIL"$(RESET)" -- 0/%s marks\n\n" $$k $$g $$mc; fi; \
		g=$$((g + 1)); \
		for lm in $$(echo $$limits | tr , ' '); do l=$${lm%/*}; mt=$${lm#*/}; total=$$((total + mt)); \
			echo "TCG $$g ($$mt mark$$([ $$mt = 1 ] || echo s)): $$k time <= $${l}x reference"; \
			if [ -z "$$y" ]; then printf "  needs TCG %s\n"$(RED)"TCG %s FAIL"$(RESET)" -- 0/%s marks\n\n" $$cg $$g $$mt; \
			else q=$$(awk -v y=$$y -v r=$$r 'BEGIN {printf "%.2f", y / r}'); \
				if awk -v y=$$y -v r=$$r -v l=$$l 'BEGIN {exit !(y <= l * r)}'; then \
					printf "  %s ms = %sx reference %s ms\n"$(GREEN)"TCG %s PASS"$(RESET)" -- %s/%s marks\n\n" $$y $$q $$r $$g $$mt $$mt; score=$$((score + mt)); \
				else printf "  %s ms = %sx reference %s ms\n"$(RED)"TCG %s FAIL"$(RESET)" -- 0/%s marks\n\n" $$y $$q $$r $$g $$mt; fi; \
			fi; g=$$((g + 1)); \
		done; \
	done; \
	echo "task3: $$score/$$total marks"; \
	echo "Times on lab machines are indicative. Final grading runs every submission on one machine."; echo

# ==== TASK 4: MIPS64 programs, run in EduMIPS64 by ./run_edumips.sh ====
# The tests replace the .data section with N elements a[i] = (37*i + 11) % 1000,
# b[i] = (53*i + 7) % 1000, and expect c[i] = 5*a[i] + b[i].
FAST4   := task4/fast$(SOL).s
UNROLL4 := task4/unroll$(SOL).s
TESTS4_FAST   := 1 7 100 1024
TESTS4_UNROLL := 1 2 7 100 1023
# Cycle budgets (no forwarding) for the last N of the tests, and their marks.
BUDGETS4_FAST   := 17486 15438 13390
MARKS4_FAST     := 1 1 2
BUDGETS4_UNROLL := 9803
MARKS4_UNROLL   := 4

define GEN4
BEGIN {
  printf "        .data\nn:      .word %d                  ; N, the number of elements\n", n
  for (i = 0; i < n; i++) {
    if (i % 16 == 0) printf "%s", (i ? "\n        .word " : "a:      .word ")
    else printf ", "
    printf "%d", (37 * i + 11) % 1000
  }
  for (i = 0; i < n; i++) {
    if (i % 16 == 0) printf "%s", "\n" (i ? "        .word " : "b:      .word ")
    else printf ", "
    printf "%d", (53 * i + 7) % 1000
  }
  printf "\nc:      .space %d                ; N words, written by the program\n\n", 8 * n
}
endef
define EXPECT4
BEGIN { printf "c:"; for (i = 0; i < n; i++) printf " %d", 5 * ((37 * i + 11) % 1000) + (53 * i + 7) % 1000; print "" }
endef
export GEN4 EXPECT4

# Shell snippet: build .tmp/<program>.<n>.s from the generated data and the .text section of $p.
BUILD4 = mkdir -p .tmp; t=.tmp/$$(basename $$p .s).$$n.s; { awk -v n=$$n "$$GEN4"; sed -n '/^[[:space:]]*\.text/,$$p' $$p; } > $$t
# Shell snippet: number of ld instructions after the setup block of $p, and of multiply instructions.
NLD4  = $$(sed -n '/end of setup/,$$p' $$p | sed 's/;.*//' | grep -ciE '^[[:space:]]*([[:alnum:]_]+:)?[[:space:]]*ld[[:space:]]')
NMUL4 = $$(sed 's/;.*//' $$p | grep -ciE '^[[:space:]]*([[:alnum:]_]+:)?[[:space:]]*d?mul')

.PHONY: task4 task4-check

# `make task4` prints c for N = 7 and the cycle counts of loop.s, fast.s and unroll.s, without forwarding.
task4:
	@printf "%-26s %5s %15s  %s\n" program N "no forwarding" "c (N = 7)"; \
	for p in task4/loop.s $(FAST4) $(UNROLL4); do ns="7 1024"; [ $$p = $(UNROLL4) ] && ns="7 1023"; for n in $$ns; do $(BUILD4); \
		a=$$(./run_edumips.sh $$t nofwd); \
		c=$$(echo "$$a" | sed -n 's/^c: //p'); [ $$n = 7 ] || c=; \
		printf "%-26s %5s %15s  %s\n" $$p $$n "$$(echo "$$a" | sed -n 's/^cycles: //p' | grep . || echo FAIL)" "$$c"; \
	done; done; \
	echo "Run make task4-check for the testcases used for grading."

# `make task4-check`: for each part, TCG "correct" checks c for every N and the instruction rules,
# then one TCG per cycle budget (largest N, no forwarding), which needs the correct TCG to pass.
task4-check:
	@echo "---- task4 ----"; score=0; total=0; g=1; \
	tcg() { total=$$((total + $$2)); if [ -n "$$pass" ]; then printf $(GREEN)"TCG %s PASS"$(RESET)" -- %s/%s marks\n\n" $$1 $$2 $$2; score=$$((score + $$2)); \
		else printf $(RED)"TCG %s FAIL"$(RESET)" -- 0/%s marks\n\n" $$1 $$2; fi; }; \
	part() { p=$$1; nld=$$2; m0=$$3; tests=$$4; budgets=$$5; marks=$$6; \
		cg=$$g; echo "TCG $$g ($$m0 mark$$([ $$m0 = 1 ] || echo s)): $$p correct"; pass=1; cyc=; \
		if [ $(NLD4) -ne $$nld ] || [ $(NMUL4) -ne 0 ]; then pass=; \
			printf "  "$(RED)"FAIL"$(RESET)" -- %s must have exactly %s ld after the setup block and no multiply\n" $$p $$nld; fi; \
		for n in $$tests; do [ -n "$$pass" ] || break; $(BUILD4); \
			out=$$(./run_edumips.sh $$t nofwd); want=$$(awk -v n=$$n "$$EXPECT4"); \
			got=$$(echo "$$out" | sed -n '/^c:/p'); \
			if [ -z "$$(echo "$$out" | sed -n 's/^cycles: //p')" ]; then pass=; \
				printf "  "$(RED)"FAIL"$(RESET)" -- %s N=%s (did not load, crashed or did not finish; run: ./run_edumips.sh %s)\n" $$p $$n $$t; \
			elif [ "$$got" = "$$want" ]; then printf "  "$(GREEN)"PASS"$(RESET)" -- %s N=%s\n" $$p $$n; \
			else pass=; printf "  "$(RED)"FAIL"$(RESET)" -- %s N=%s (c is wrong; run: ./run_edumips.sh %s)\n" $$p $$n $$t; fi; \
			cyc=$$(echo "$$out" | sed -n 's/^cycles: //p'); nt=$$n; \
		done; \
		ok=$$pass; tcg $$g $$m0; g=$$((g + 1)); \
		set -- $$marks; for b in $$budgets; do m=$$1; shift; echo "TCG $$g ($$m mark$$([ $$m = 1 ] || echo s)): $$p cycles"; pass=1; \
			if [ -z "$$ok" ]; then pass=; echo "  needs TCG $$cg"; \
			elif [ $$cyc -le $$b ]; then printf "  "$(GREEN)"PASS"$(RESET)" -- %s cycles %s <= %s (N=%s, no forwarding)\n" $$p $$cyc $$b $$nt; \
			else pass=; printf "  "$(RED)"FAIL"$(RESET)" -- %s cycles %s > %s (N=%s, no forwarding)\n" $$p $$cyc $$b $$nt; fi; \
			tcg $$g $$m; g=$$((g + 1)); \
		done; }; \
	part $(FAST4) 2 1 "$(TESTS4_FAST)" "$(BUDGETS4_FAST)" "$(MARKS4_FAST)"; \
	part $(UNROLL4) 6 3 "$(TESTS4_UNROLL)" "$(BUDGETS4_UNROLL)" "$(MARKS4_UNROLL)"; \
	echo "task4: $$score/$$total marks"; echo

ifdef tasks

# 1. Run find at build time in Make's environment
FOUND_FILES := $(shell find -L $(addprefix ./,$(tasks)) \
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

.SUFFIXES:

# task1: x86-64 assembly, linked with ld (no libc).
# task2: C++, compiled with g++ -O0 and run pinned to one core.
# task3: x86-64 assembly, linked with gcc -no-pie -nostartfiles (libc).
# task4: MIPS64 program, run in the EduMIPS64 snap (`edumips64`).
AS := nasm
ASFLAGS := -g -f elf64
CXX := g++
CXXFLAGS := -g -O0 -std=c++23
CPU ?= 1

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

# solution_makefile sets SUFFIX := _solution to build the reference solutions.
SUFFIX ?=

# EduMIPS64 is the snap (command `edumips64`), installed on the SL machines.
EDU := edumips64

.PHONY: default task1 task2 task3 task4 task4-tests check4 clean
# Always rebuild: make and solution-make write the same .out files.
.PHONY: task1.out task2.out task3.out

default:
	@printf "Usage: make [task1|task2|task3|task4|check4]\n"

task1: task1.out
	@echo "./task1.out"
	@./task1.out; echo "Return Code: $$?"

task2: task2.out
	@echo "taskset -c $(CPU) ./task2.out"
	@taskset -c $(CPU) ./task2.out

task3: task3.out
	@echo "./task3.out $(args)"
	@./task3.out $(args); printf "\nReturn Code: %d\n" $$?

task1.out: task1/poly_eval$(SUFFIX).s
	$(AS) $(ASFLAGS) -o task1/poly_eval$(SUFFIX).o $<
	ld -o $@ task1/poly_eval$(SUFFIX).o

task2.out: task2/poly$(SUFFIX).cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

task3.out: task3/adder$(SUFFIX).s
	$(AS) $(ASFLAGS) -o task3/adder$(SUFFIX).o $<
	gcc -no-pie -nostartfiles -o $@ task3/adder$(SUFFIX).o

# Task 4 runs on generated test data: N elements with a[i] = (7*i + 3) % 100 and b[i] = (13*i + 5) % 100,
# so c[i] = a[i] + b[i]. `make check4` also runs the edge sizes N = 0, 1 and 3.
TESTS4 = 8 6 9 1024 2047 4098
EDGE4 = 0 1 3
GENERAL = task4/general$(SUFFIX).s
SPECS4 = $(foreach p,task4/loop.s $(GENERAL),$(foreach n,$(TESTS4),$(p):$(n)))
CHECKS4 = $(foreach n,$(TESTS4) $(EDGE4),$(GENERAL):$(n))

define GEN_DATA
BEGIN {
  printf "        .data\nn:      .word %d                  ; N, the number of elements\n", n
  if (n == 0) printf "a:\nb:\n"
  for (i = 0; i < n; i++) {
    if (i % 16 == 0) printf "%s", (i ? "\n" : "") (i ? "        .word " : "a:      .word ")
    else printf ", "
    printf "%d", (7 * i + 3) % 100
  }
  for (i = 0; i < n; i++) {
    if (i % 16 == 0) printf "%s", "\n" (i ? "        .word " : "b:      .word ")
    else printf ", "
    printf "%d", (13 * i + 5) % 100
  }
  if (n == 0) printf "c:\n"
  else printf "\nc:      .space %d                ; N words, filled in by the program\n", 8 * n
}
endef
define EXPECT
BEGIN { if (n == 0) printf "0 "   # the simulator pads an empty label with one zero word
  for (i = 0; i < n; i++) printf "%d ", (7 * i + 3) % 100 + (13 * i + 5) % 100 }
endef
export GEN_DATA EXPECT

BUILD = mkdir -p .tmp; p=$${s%:*}; n=$${s\#*:}; t=.tmp/$$(basename $$p .s).$$n.s; { awk -v n=$$n "$$GEN_DATA"; sed -n '/^ *\.text/,$$p' $$p; } > $$t

NOEDU = command -v $(EDU) >/dev/null || { echo "Error: edumips64 not found. Install it with: sudo snap install edumips64, or use the web version: https://web.edumips.org"; exit 1; }

# `make task4` prints the cycle counts of loop.s and general.s on every test size.
task4:
	@$(NOEDU); \
	printf "%-32s %6s %15s %12s\n" program N "no forwarding" forwarding; \
	for s in $(SPECS4); do $(BUILD); \
		a=$$(./run_edumips.sh $$t nofwd cycles 2>&1 | sed -n 's/^cycles: //p'); b=$$(./run_edumips.sh $$t fwd cycles 2>&1 | sed -n 's/^cycles: //p'); \
		printf "%-32s %6s %15s %12s\n" $$p $$n "$${a:-FAIL}" "$${b:-FAIL}"; done; \
	echo "Cycle counts only mean something for a program that passes make check4."

# `make task4-tests` writes the test data as text, to paste over the .data section in the web version.
task4-tests:
	@{ echo "; Test data for task4. Paste one test over the .data section of your program (from the .data line"; \
	echo "; up to, but not including, the .text line), run it, and compare c in the Memory panel."; \
	for n in $(TESTS4); do \
		echo; echo "; ===== task4 test: N = $$n ====="; \
		first=$$(awk -v n=$$n "$$EXPECT" | cut -d' ' -f1-4); last=$$(awk -v n=$$n "$$EXPECT" | awk '{print $$(NF-3), $$(NF-2), $$(NF-1), $$NF}'); \
		echo "; expected c[0..3]     : $$first   (hex: $$(echo $$first | awk '{for (i = 1; i <= NF; i++) printf "%X ", $$i}'))"; \
		echo "; expected c[N-4..N-1] : $$last   (hex: $$(echo $$last | awk '{for (i = 1; i <= NF; i++) printf "%X ", $$i}'))"; \
		awk -v n=$$n "$$GEN_DATA"; \
	done; } > task4/tests.txt; echo "wrote task4/tests.txt"

# `make check4` runs general.s on every test size and compares the array c with the expected values.
check4:
	@$(NOEDU); \
	for s in $(CHECKS4); do $(BUILD); \
		out=$$(printf 'load %s\nrun\nshow memory\nexit\n' $$(realpath $$t) | timeout 120 $(EDU) --headless --no-banner -v 2>&1); \
		if ! echo "$$out" | grep -q 'Execution ended'; then \
			printf $(RED)"FAIL"$(RESET)" -- %s N=%s (did not load, crashed, or did not finish; run: ./run_edumips.sh %s)\n" $$p $$n $$t; continue; \
		fi; \
		got=$$(echo "$$out" | awk 'function h(s,i,v){v=0;for(i=1;i<=length(s);i++)v=v*16+index("0123456789ABCDEF",substr(s,i,1))-1;return v} /LABEL  c,/{f=1} f&&/^ADDRESS/{printf "%d ",h(substr($$0,index($$0,"VALUE ")+6,16))}'); \
		want=$$(awk -v n=$$n "$$EXPECT"); \
		if [ "$$got" = "$$want" ]; then printf $(GREEN)"PASS"$(RESET)" -- %s N=%s\n" $$p $$n; \
		else msg=$$(awk -v g="$$got" -v w="$$want" 'BEGIN{ng=split(g,G," "); nw=split(w,W," "); for(i=1;i<=nw;i++) if (G[i]!=W[i]) {printf "c[%d] is %s, want %s", i-1, (i<=ng ? G[i] : "missing"), W[i]; exit} if (ng>nw) printf "%d word(s) written past the end of c", ng-nw}'); \
			printf $(RED)"FAIL"$(RESET)" -- %s N=%s (%s)\n" $$p $$n "$$msg"; fi; \
	done

clean:
	@rm -fv task1.out task2.out task3.out */*.o task4/tests.txt; rm -rf .tmp

.SUFFIXES:

AS := nasm

LD := g++
LDFLAGS := -no-pie

ASFLAGS := -g -f elf64
CFLAGS := -g -O0
CXXFLAGS := -g -O0 -std=c++23

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

# The timing tasks (4 to 6) run pinned to one core: `make task4 CPU=2` runs on core 2 (default 0).
CPU ?= 0

# The MIPS programs run in the bundled executable ./edumips64 (no Java needed) when it works,
# otherwise in the jar with java. EDUMIPS64_FORCE_JAR=1 forces the jar.
EDU := $(shell if [ -x ./edumips64 ] && [ -z "$$EDUMIPS64_FORCE_JAR" ] && ./edumips64 --selftest >/dev/null 2>&1; then echo ./edumips64; else echo java -jar edumips64-1.4.0.jar; fi)

# Tasks 1 to 3 are MIPS64 programs run in the EduMIPS64 jar; the rest are built natively.
MIPS_TASKS = task1
TASKS = $(filter-out $(MIPS_TASKS) task2 task3,$(patsubst %/,%,$(wildcard */)))
TASKS_OUT = $(patsubst %,%.out,$(TASKS))

.PHONY: all clean

default:
	@printf "Usage: make [task]\n"

# Task 7 is compiled with -O2: the bugs it is about only appear when the compiler optimizes.
task7/%.o: CXXFLAGS = -g -O2 -std=c++17

# `make check7` fails when the time printed by task 7 is impossible for 100000 multiply-adds.
.PHONY: check7
check7: task7.out
	@ns=$$(taskset -c $(CPU) ./task7.out | sed -n 's/^dot: \([0-9.]*\) ns.*/\1/p'); \
	if [ -n "$$ns" ] && awk -v x="$$ns" 'BEGIN{exit !(x > 20000)}'; then \
		printf $(GREEN)"PASS"$(RESET)" -- task7: %s ns per dot product is plausible\n" "$$ns"; \
	else printf $(RED)"FAIL"$(RESET)" -- task7: %s ns is too fast for 100000 multiply-adds\n" "$${ns:-no number}"; fi

.PHONY: $(TASKS_OUT)

$(TASKS): %: %.out
	@echo "taskset -c $(CPU) ./$*.out $(args)"
	@taskset -c $(CPU) ./$*.out $(args); printf "\nReturn Code: %d\n" $$?


# `make taskN` runs the program without and with forwarding (args="fwd" or args="nofwd" for one).
.PHONY: $(MIPS_TASKS)
$(MIPS_TASKS): %:
	@for f in $(filter-out %_solution.s,$(wildcard $*/*.s)); do for m in $(or $(args),nofwd fwd); do echo "== $$f"; ./run_edumips.sh $$f $$m; echo; done; done

# Tasks 2 and 3 run on generated test data: N elements with a[i] = (7*i + 3) % 100 and b[i] = (13*i + 5) % 100,
# so c[i] = a[i] + b[i]. `make task2-tests` and `make task3-tests` write the same data as text (see below).
TESTS2 = 8 4096
TESTS3 = 8 6 9 1024 2047 4098
PROGS2 = task2/loop.s task2/unroll2.s task2/unroll4.s
PROGS3 = task2/loop.s task3/general.s
CHECK2 = task2/unroll2.s task2/unroll4.s
CHECK3 = task3/general.s
SPECS2 = $(foreach p,$(PROGS2),$(foreach n,$(TESTS2),$(p):$(n)))
SPECS3 = $(foreach p,$(PROGS3),$(foreach n,$(TESTS3),$(p):$(n)))
# `make check` also runs task 3 on the edge sizes N = 0, 1 and 3 (fewer elements than one iteration of loop4).
EDGE3 = 0 1 3
CHECKS2 = $(foreach p,$(CHECK2),$(foreach n,$(TESTS2),$(p):$(n)))
CHECKS3 = $(foreach p,$(CHECK3),$(foreach n,$(TESTS3) $(EDGE3),$(p):$(n)))

# awk programs (called with -v n=N): the .data section of a test, and the values c must hold.
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

# Shell snippet, used inside the recipes below: for one spec "program:N" build .tmp/<program>.<N>.s
# from the generated data section and the .text section of the program.
BUILD = mkdir -p .tmp; p=$${s%:*}; n=$${s\#*:}; t=.tmp/$$(basename $$p .s).$$n.s; { awk -v n=$$n "$$GEN_DATA"; sed -n '/^ *\.text/,$$p' $$p; } > $$t

.PHONY: task2 task3 task2-tests task3-tests check check2 check3

# `make task2` and `make task3` print the cycle count of every program on every test size.
# FAIL means the program did not load, crashed or did not finish; use `make check` for correctness.
task2 task3:
	@case "$(EDU)" in java*) command -v java >/dev/null || { echo "Error: cannot run the tests locally (./edumips64 does not work and no Java was found). Use the web version instead: https://web.edumips.org"; exit 1; };; esac; \
	printf "%-32s %6s %15s %12s\n" program N "no forwarding" forwarding; \
	for s in $(if $(filter task2,$@),$(SPECS2),$(SPECS3)); do $(BUILD); \
		a=$$(./run_edumips.sh $$t nofwd cycles 2>&1 | sed -n 's/^cycles: //p'); b=$$(./run_edumips.sh $$t fwd cycles 2>&1 | sed -n 's/^cycles: //p'); \
		printf "%-32s %6s %15s %12s\n" $$p $$n "$${a:-FAIL}" "$${b:-FAIL}"; done; \
	echo "Cycle counts only mean something for a program that passes make check."

# `make task2-tests` and `make task3-tests` write the test data as text, to paste over the .data section
# of a program (for example in the web version of EduMIPS64).
task2-tests task3-tests: %-tests:
	@{ echo "; Test data for $*. Paste one test over the .data section of your program (from the .data line"; \
	echo "; up to, but not including, the .text line), run it, and compare c in the Memory panel."; \
	for n in $(if $(filter task2,$*),$(TESTS2),$(TESTS3)); do \
		echo; echo "; ===== $* test: N = $$n ====="; \
		first=$$(awk -v n=$$n "$$EXPECT" | cut -d' ' -f1-4); last=$$(awk -v n=$$n "$$EXPECT" | awk '{print $$(NF-3), $$(NF-2), $$(NF-1), $$NF}'); \
		echo "; expected c[0..3]     : $$first   (hex: $$(echo $$first | awk '{for (i = 1; i <= NF; i++) printf "%X ", $$i}'))"; \
		echo "; expected c[N-4..N-1] : $$last   (hex: $$(echo $$last | awk '{for (i = 1; i <= NF; i++) printf "%X ", $$i}'))"; \
				awk -v n=$$n "$$GEN_DATA"; \
	done; } > $*/tests.txt; echo "wrote $*/tests.txt"

# `make check` runs the programs on every test size and compares the array c with the expected values.
# `make check2` and `make check3` do the same for Task 2 or Task 3 only.
check2: CHECKSPECS = $(CHECKS2)
check3: CHECKSPECS = $(CHECKS3)
check: CHECKSPECS = $(CHECKS2) $(CHECKS3)
check check2 check3:
	@case "$(EDU)" in java*) command -v java >/dev/null || { echo "Error: cannot run the tests locally (./edumips64 does not work and no Java was found). Use the web version instead: https://web.edumips.org"; exit 1; };; esac; \
	for s in $(CHECKSPECS); do $(BUILD); \
		out=$$(printf 'load %s\nrun\nshow memory\nexit\n' $$t | timeout 120 $(EDU) --headless --no-banner -v 2>&1); \
		if ! echo "$$out" | grep -q 'Execution ended'; then \
			printf $(RED)"FAIL"$(RESET)" -- %s N=%s (did not load, crashed, or did not finish; run: ./run_edumips.sh %s)\n" $$p $$n $$t; continue; \
		fi; \
		got=$$(echo "$$out" | awk 'function h(s,i,v){v=0;for(i=1;i<=length(s);i++)v=v*16+index("0123456789ABCDEF",substr(s,i,1))-1;return v} /LABEL  c,/{f=1} f&&/^ADDRESS/{printf "%d ",h(substr($$0,index($$0,"VALUE ")+6,16))}'); \
		want=$$(awk -v n=$$n "$$EXPECT"); \
		if [ "$$got" = "$$want" ]; then printf $(GREEN)"PASS"$(RESET)" -- %s N=%s\n" $$p $$n; \
		else msg=$$(awk -v g="$$got" -v w="$$want" 'BEGIN{ng=split(g,G," "); nw=split(w,W," "); for(i=1;i<=nw;i++) if (G[i]!=W[i]) {printf "c[%d] is %s, want %s", i-1, (i<=ng ? G[i] : "missing"), W[i]; exit} if (ng>nw) printf "%d word(s) written past the end of c", ng-nw}'); \
			printf $(RED)"FAIL"$(RESET)" -- %s N=%s (%s)\n" $$p $$n "$$msg"; fi; \
	done

.SECONDEXPANSION:

get_all_o_files = $(addsuffix .o, $(basename $(wildcard $1/*.s $1/*.c $1/*.cpp)))
get_sol_o_files = $(filter %_solution.o, $(call get_all_o_files,$1))
get_oth_o_files = $(filter-out $(call get_sol_o_files,$1),$(call get_all_o_files,$1))

$(TASKS_OUT): %.out: $$(call get_oth_o_files,$$*)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $<
	
%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<
	
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
	
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	@rm -fv $(TASKS_OUT) */*.o task2/tests.txt task3/tests.txt; rm -rf .tmp
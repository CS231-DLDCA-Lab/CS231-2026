.SUFFIXES:

AS := nasm

LD := gcc
LDFLAGS := -no-pie -nostartfiles

ASFLAGS := -g -f elf64
CFLAGS := -g -O0
CXXFLAGS := -g -O0 -std=c++23

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

TASKS = $(patsubst %/,%,$(wildcard */))
TASKS_OUT = $(patsubst %,%.out,$(TASKS))

.PHONY: all clean

default:
	@printf "Usage: make [task]\n"

.PHONY: $(TASKS_OUT)

$(TASKS): %: %.out
	@echo "./$*.out $(args)"
	@./$*.out $(args); printf "\nReturn Code: %d\n" $$?


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
	$(CC) $(CFLAGS) -o $@ $<
	
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# --- Lab exam (labexam/): my_atoi given, student writes _start in raceclock.s ---
# `make labexam` runs it once on piped stdin; `make labexam-check` runs every
# case in labexam/tests/ (N.in with expected output N.out).
.PHONY: labexam-check
labexam-check: labexam.out
	@for t in labexam/tests/*_input.txt; do \
		exp="$${t%_input.txt}_output.txt"; \
		./labexam.out < "$$t" > ".got"; \
		if [ -z "`diff "$$exp" ".got"`" ]; then \
			printf $(GREEN)"PASS"$(RESET)" -- %s (`cat $$t`)\n" "$$t"; \
		else \
			printf $(RED)"FAIL"$(RESET)" -- %s (got `cat ".got"`, want `cat "$$exp"`)\n" "$$t"; \
		fi; \
 		rm -f ".got"; \
	done

clean:
	@rm -fv $(TASKS_OUT) */*.o .got
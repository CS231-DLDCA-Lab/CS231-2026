.SUFFIXES:

AS := nasm
# LD := gcc
# LD := g++

ASFLAGS := -g -f elf64
CFLAGS := -g -O0
CXXFLAGS := -g -O0 -std=c++23
LDFLAGS := 

TASKS = $(patsubst %/,%,$(wildcard */))
TASKS_OUT = $(patsubst %,%.out,$(TASKS))

.PHONY: all clean

default:
	@printf "Usage: make [task]\n"

.PHONY: $(TASKS_OUT)

$(TASKS): %: %.out
	@echo "./$*.out"
	@./$*.out; echo "Return Code: $$?"

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

clean:
	@rm -fv $(TASKS_OUT) */*.o
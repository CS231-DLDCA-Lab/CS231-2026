.SUFFIXES:

# Task 1: 2D convolution, one binary per stage.
#   make conv_naive        build and run the naive stage (2048 x 2048, K=3)
#   make conv_reorder      ... the reorder stage, and so on (conv_simd, conv_unroll)
#   make all               build every stage
#   make <stage> args="1024 1024 5"   pass size / reps to the binary
#   make check             build and run every stage, print PASS/FAIL
#   make clean
#
# Measure a stage with perf once it is built, e.g.:  perf stat -d ./conv_simd.out

# Pick the first available compiler.
CXX := $(firstword $(foreach c,g++-13 g++-12 g++-11 g++,$(if $(shell command -v $(c) 2>/dev/null),$(c))))
ifeq ($(CXX),)
$(error no g++ found)
endif

# -O2 so the code is realistic; -fno-tree-vectorize so the compiler does not silently
# vectorise the scalar stages (you add SIMD yourself). SSE is baseline on x86-64.
CXXFLAGS := -g -O2 -fno-tree-vectorize -std=c++17
CPU ?= 1
RUN := taskset -c $(CPU)

STAGES := conv_naive conv_reorder conv_simd conv_unroll

# solution_makefile sets SUFFIX := _solution to build the reference versions.
SUFFIX ?=
src = $(if $(wildcard $1$(SUFFIX).cpp),$1$(SUFFIX).cpp,$1.cpp)

RED   := "\\033[31m"
GREEN := "\\033[32m"
RESET := "\\033[0m"

.PHONY: default all check clean $(STAGES)
default:
	@printf "Usage: make <stage> [args=\"H W K [reps]\"] [CPU=n]\n  stages: $(STAGES)\n"

# conv_naive is always built from conv_naive.cpp (no solution variant).
conv_naive.out: conv_naive.cpp main.cpp convolution.h
	$(CXX) $(CXXFLAGS) -o $@ conv_naive.cpp main.cpp
conv_reorder.out: $(call src,conv_reorder) main.cpp convolution.h
	$(CXX) $(CXXFLAGS) -o $@ $(call src,conv_reorder) main.cpp
conv_simd.out: $(call src,conv_simd) main.cpp convolution.h
	$(CXX) $(CXXFLAGS) -o $@ $(call src,conv_simd) main.cpp
conv_unroll.out: $(call src,conv_unroll) main.cpp convolution.h
	$(CXX) $(CXXFLAGS) -o $@ $(call src,conv_unroll) main.cpp

# student and solution builds share .out names, so always rebuild.
.PHONY: $(addsuffix .out,$(STAGES))

$(STAGES): %: %.out
	@echo "$(RUN) ./$*.out $(args)"
	@$(RUN) ./$*.out $(args)

all: $(addsuffix .out,$(STAGES))

check: $(addsuffix .out,$(STAGES))
	@for s in $(STAGES); do \
		line=$$($(RUN) ./$$s.out $(args) | grep -E '^(PASS|FAIL)'); \
		t=$$($(RUN) ./$$s.out $(args) | awk '/^time:/ {print $$2}'); \
		case "$$line" in PASS*) c=$(GREEN);; *) c=$(RED);; esac; \
		printf "%-14s $$c%s$(RESET)  (%s ms)\n" "$$s" "$$line" "$$t"; \
	done

clean:
	@rm -fv $(addsuffix .out,$(STAGES))

#!/usr/bin/env bash
set -e

RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
NC=$(printf '\033[0m')

read -rp "Enter Student Roll Number: " ROLL_NO
if [ -z "$ROLL_NO" ]; then
    printf "${RED}Error: Roll number cannot be empty.${NC}\n" >&2
    exit 1
fi

# Validate Roll Number against allowed range (901 to 1100)
VALID_PATTERN="^(210050102|2[345]b(090[1-9]|09[1-9][0-9]|10[0-9][0-9]|1100))$"

if ! echo "$ROLL_NO" | grep -qE "$VALID_PATTERN" ; then
    printf "${RED}Error: Invalid student ID. Please check the ID and try again.${NC}\n" >&2
    exit 1
fi

mkdir -p "$ROLL_NO"

FILES=(./task1/test_average.c ./task1/average.s ./task1/write.s ./task1/test_full.c ./task1/dispatch.s ./task1/test_dispatch.c ./task1/test_write.c ./task2/call_binom.s ./task2/binom.s ./task2/test_binom.c ./task3/reference ./task3/base.cpp ./task3/kernels.h ./task3/fast.cpp ./task3/main.cpp ./task4/fast.s ./task4/unroll.s ./task4/loop.s)

echo "Packaging assignment files..."
for file in "${FILES[@]}"; do
    if [ -e "$file" ] || [ -L "$file" ]; then
        mkdir -p "$ROLL_NO/$(dirname "$file")"
        cp -RP "$file" "$ROLL_NO/$file"
        printf "  ${GREEN}[+] Copied:${NC} %s\n" "$file"
    else
        printf "${RED}Error: Required file or symlink missing: %s${NC}\n" "$file" >&2
        rm -rf "$ROLL_NO"
        exit 1
    fi
done

tar -czf "${ROLL_NO}.tar.gz" "$ROLL_NO"
rm -rf "$ROLL_NO"
printf "${GREEN}Successfully created ${ROLL_NO}.tar.gz${NC}\n"

#!/bin/bash
# Usage: ./check_tests.sh name [bin [testsdir]]
# Defaults: bin = ./name.out, testsdir = name/tests.
# Runs bin on testsdir/NN_input.txt and compares its output with NN_output.txt.
# testsdir/groups.txt has one testcase group (TCG) per line:   group marks NN...
# A group gets its marks only if every test in it passes.
task=${1:?usage: $0 name [bin [testsdir]]}
bin=${2:-./$task.out}
testsdir=${3:-$task/tests}
got=$testsdir/.got
trap 'rm -f "$got"' EXIT
RED='\033[31m' GREEN='\033[32m' RESET='\033[0m'

# run_test NN: print PASS/FAIL; a failure also prints the diff command
run_test() {
    local in=$testsdir/$1_input.txt out=$testsdir/$1_output.txt
    "$bin" < "$in" > "$got"
    if diff -q "$out" "$got" >/dev/null 2>&1; then
        printf "  ${GREEN}PASS${RESET} -- %s\n" "$in"
    else
        printf "  ${RED}FAIL${RESET} -- %s    see: %s < %s | diff %s -\n" "$in" "$bin" "$in" "$out"
        return 1
    fi
}

score=0 total=0
while read -r g marks tests; do
    [[ -z $g || $g == \#* ]] && continue
    [ "$marks" = 1 ] && u=mark || u=marks; echo "TCG $g ($marks $u)"
    ok=1
    for n in $tests; do run_test "$n" || ok=; done
    total=$((total + marks))
    if [ -n "$ok" ]; then
        printf "${GREEN}TCG %s PASS${RESET} -- %s/%s marks\n\n" "$g" "$marks" "$marks"; score=$((score + marks))
    else
        printf "${RED}TCG %s FAIL${RESET} -- 0/%s marks\n\n" "$g" "$marks"
    fi
done < "$testsdir/groups.txt"
echo "$task: $score/$total marks"

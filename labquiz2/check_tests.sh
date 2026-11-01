#!/bin/bash
# Usage: ./check_tests.sh taskN [cpu]
# Runs ./taskN.out on every taskN/tests/NN_input.txt and compares its output with NN_output.txt.
# Hidden tests live in taskN/hidden/ (NN_input_solution.txt, NN_output_solution.txt) and are
# present only on the grader's setup.
#
# If taskN/tests/groups.txt exists, the tests are reported by testcase group (TCG). Each line is
#     group marks test...
# where a test is NN (taskN/tests/NN_input.txt) or the word hidden (every test in taskN/hidden/).
# A group gets its marks only if every test in it passes.
task=${1:?usage: $0 taskN [cpu]}
cpu=${2:-1}
bin=./$task.out
got=$task/tests/.got
trap 'rm -f "$got"' EXIT
RED='\033[31m' GREEN='\033[32m' RESET='\033[0m'
hidden_msg="Hidden testcases missing, will be present on grader's setup."

# run_test input expected [show]: print PASS/FAIL; with show, a failure prints the diff command
run_test() {
    taskset -c "$cpu" "$bin" < "$1" > "$got"
    if diff -q "$2" "$got" >/dev/null 2>&1; then
        printf "  ${GREEN}PASS${RESET} -- %s\n" "$1"
    else
        printf "  ${RED}FAIL${RESET} -- %s" "$1"
        [ -n "$3" ] && printf "    see: %s < %s | diff %s -" "$bin" "$1" "$2"
        printf "\n"
        return 1
    fi
}

hidden_inputs=( "$task"/hidden/*_input_solution.txt )
[ -e "${hidden_inputs[0]}" ] || hidden_inputs=()

# run_hidden: run every hidden test; returns 1 if one fails
run_hidden() {
    local ok=0
    for t in "${hidden_inputs[@]}"; do
        run_test "$t" "${t%_input_solution.txt}_output_solution.txt" || ok=1
    done
    return $ok
}

groups=$task/tests/groups.txt
if [ ! -f "$groups" ]; then
    set -- "$task"/tests/*_input.txt
    if [ ! -e "$1" ]; then echo "$task: no testcases here, run make $task"; exit 0; fi
    for t in "$@"; do run_test "$t" "${t%_input.txt}_output.txt" show; done
    if [ ${#hidden_inputs[@]} -eq 0 ]; then echo "$hidden_msg"; else run_hidden; fi
    exit 0
fi

score=0 total=0
while read -r g marks tests <&3; do
    [[ -z $g || $g == \#* ]] && continue
    [ "$marks" = 1 ] && u=mark || u=marks; echo "TCG $g ($marks $u)"
    ok=0
    for n in $tests; do
        if [ "$n" = hidden ]; then
            if [ ${#hidden_inputs[@]} -eq 0 ]; then echo "  $hidden_msg"; ok=2; else run_hidden || ok=1; fi
        else
            run_test "$task/tests/${n}_input.txt" "$task/tests/${n}_output.txt" show || ok=1
        fi
    done
    case $ok in
        0) printf "${GREEN}TCG %s PASS${RESET} -- %s/%s marks\n\n" "$g" "$marks" "$marks"; score=$((score + marks)); total=$((total + marks)) ;;
        1) total=$((total + marks)); printf "${RED}TCG %s FAIL${RESET} -- 0/%s marks\n\n" "$g" "$marks" ;;
        2) printf "TCG %s not run -- ?/%s marks\n\n" "$g" "$marks" ;;
    esac
done 3< "$groups"
echo "$task: $score/$total marks from the groups that ran"

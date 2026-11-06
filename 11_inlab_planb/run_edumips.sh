#!/bin/bash
# Usage: ./run_edumips.sh prog.s [fwd|nofwd] [trace|cycles]   (cycles: only the cycle count, fast)
# Runs prog.s in headless EduMIPS64 (the snap, command `edumips64`) and prints cycles,
# instructions and CPI.
# Forwarding is a stored preference, and the snap keeps its preferences in
# ~/snap/edumips64/current/.java. We set forwarding there for this run and put your
# own preferences back when the script exits.
prog=${1:?usage: $0 prog.s [fwd|nofwd] [trace]}
mode=${2:-nofwd}
command -v edumips64 >/dev/null || { echo "Error: edumips64 not found. Install it with: sudo snap install edumips64, or use the web version: https://web.edumips.org"; exit 1; }
# The snap cannot see /tmp and resolves paths from its own directory, so pass an absolute path.
prog=$(realpath "$prog")
run() { timeout 30 edumips64 --headless --no-banner "$@"; }
prefsdir="$HOME/snap/edumips64/current/.java/.userPrefs"
# A first launch creates the prefs file.
[ -n "$(find "$prefsdir" -name prefs.xml 2>/dev/null | head -1)" ] || echo exit | run >/dev/null 2>&1
prefs=$(find "$prefsdir" -name prefs.xml 2>/dev/null | head -1)
[ -n "$prefs" ] || { echo "Error: cannot find the EduMIPS64 preferences under $prefsdir"; exit 1; }
backup=$(mktemp)
cp "$prefs" "$backup"
trap 'cp "$backup" "$prefs"; rm -f "$backup"' EXIT
[ "$mode" = fwd ] && val=true || val=false
# Change only the forwarding entry, keep every other setting.
if grep -q 'key="forwarding"' "$prefs"; then
  sed -i 's|<entry key="forwarding" value="[a-z]*"/>|<entry key="forwarding" value="'"$val"'"/>|' "$prefs"
else
  sed -i 's|</map>|<entry key="forwarding" value="'"$val"'"/></map>|' "$prefs"
fi
# Stdout of the program plus the cycle count from the simulator itself.
out=$(printf 'load %s\nrun\nexit\n' "$prog" | run -v 2>&1)
cycles=$(grep -o '[0-9]* steps' <<<"$out" | cut -d' ' -f1)
if [ -z "$cycles" ]; then   # load or parse error, or the program crashed: show the simulator message
  grep -v -E '^\s+at |^(Please report|along with|to the EduMIPS64|Version:|JRE version|OS:|[A-Z][a-z]{2} [0-9]+, 20)' <<<"$out"
  if grep -q 'fatal error' <<<"$out"; then
    echo "Your program crashed: it used memory outside the .data section (for example past the end of c) or overflowed."
  elif ! grep -q -E 'errors found|Unable to' <<<"$out"; then
    echo "The program did not finish within 30 s (an endless loop?)."
  fi
  exit 1
fi
if [ "$3" = cycles ]; then echo "forwarding: $val"; echo "cycles: $cycles"; exit 0; fi   # skip the slow instruction count
# Instruction count: each `step` prints the pipeline; count real instructions in WB.
n=$cycles
trace=$( { echo "load $prog"; for _ in $(seq "$n"); do echo step; done; echo exit; } | run 2>&1)
instr=$(grep -c -E 'WB:	[A-Z]' <<<"$trace")
echo "forwarding: $val"
echo "cycles: $cycles"
echo "instructions: $instr"
awk -v c="$cycles" -v i="$instr" 'BEGIN{ printf "CPI: %.3f\n", c/i }'
[ "$3" = trace ] && grep -v -E '^\s+at |^(Please report|along with|to the EduMIPS64|Version:|JRE version|OS:|[A-Z][a-z]{2} [0-9]+, 20)' <<<"$trace"
exit 0

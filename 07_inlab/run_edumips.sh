#!/bin/bash
# Usage: ./run_edumips.sh prog.s [fwd|nofwd] [trace|cycles]   (cycles: only the cycle count, fast)
# Runs prog.s in headless EduMIPS64 and prints cycles, instructions and CPI.
# Forwarding is a stored preference in the GUI, so we run the jar with a private
# home directory whose prefs.xml sets it. Your own EduMIPS64 settings are untouched.
prog=${1:?usage: $0 prog.s [fwd|nofwd] [trace]}
mode=${2:-nofwd}
here="$(cd "$(dirname "$0")" && pwd)"
jar="$here/edumips64-1.4.0.jar"
bin="$here/edumips64"
# Prefer the bundled executable ./edumips64 (it needs no Java); fall back to java -jar.
# EDUMIPS64_FORCE_JAR=1 forces the fallback.
if [ -x "$bin" ] && [ -z "$EDUMIPS64_FORCE_JAR" ] && "$bin" --selftest >/dev/null 2>&1; then
  edu=bin
else
  command -v java >/dev/null || { echo "Error: cannot run the tests locally (./edumips64 does not work and no Java was found). Use the web version instead: https://web.edumips.org"; exit 1; }
  edu=jar
fi
home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
# A first launch creates the prefs file; then we set forwarding in it.
run() {
  if [ "$edu" = bin ]; then EDUMIPS64_JAVA_OPTS="-Duser.home=$home" timeout 30 "$bin" --headless --no-banner "$@"
  else timeout 30 java -Duser.home="$home" -jar "$jar" --headless --no-banner "$@"; fi
}
echo exit | run >/dev/null 2>&1
[ "$mode" = fwd ] && val=true || val=false
prefs=$(find "$home/.java/.userPrefs" -name prefs.xml | head -1)
cat > "$prefs" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">
<map MAP_XML_VERSION="1.0"><entry key="forwarding" value="$val"/></map>
XML
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

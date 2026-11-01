#!/bin/bash
# Usage: ./run_edumips.sh prog.s [nofwd|fwd]
# Runs prog.s in headless EduMIPS64 and prints the cycle count and the value stored at label s.
#
# EduMIPS64 comes from snap. Forwarding is a stored preference of the GUI, so we run the snap's
# own Java on the snap's jar with a private home directory whose prefs.xml sets it.
# Your own EduMIPS64 settings are untouched.
prog=${1:?usage: $0 prog.s [nofwd|fwd]}
mode=${2:-nofwd}
snap=/snap/edumips64/current
jar=$snap/jar/edumips64.jar
java=$(ls $snap/usr/lib/jvm/java-*-openjdk-*/bin/java 2>/dev/null | head -1)
[ -x "$java" ] || java=$(command -v java)
if [ ! -f "$jar" ] || [ -z "$java" ]; then
  echo "Error: EduMIPS64 not found (expected the snap in $snap). Ask a TA."
  exit 1
fi
[ -f "$prog" ] || { echo "Error: no such file: $prog"; exit 1; }
prog=$(cd "$(dirname "$prog")" && pwd)/$(basename "$prog")

home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
run() { timeout 60 "$java" -Duser.home="$home" -jar "$jar" --headless --no-banner "$@"; }
# A first launch creates the prefs file; then we set forwarding in it.
echo exit | run >/dev/null 2>&1
[ "$mode" = fwd ] && val=true || val=false
prefs=$(find "$home/.java/.userPrefs" -name prefs.xml | head -1)
cat > "$prefs" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE map SYSTEM "http://java.sun.com/dtd/preferences.dtd">
<map MAP_XML_VERSION="1.0"><entry key="forwarding" value="$val"/></map>
XML

out=$(printf 'load %s\nrun\nshow memory\nexit\n' "$prog" | run -v 2>&1)
cycles=$(grep -o '[0-9]* steps' <<<"$out" | cut -d' ' -f1)
if [ -z "$cycles" ]; then   # load or parse error, crash or timeout: show the simulator message
  grep -v -E '^\s+at |^(Please report|along with|to the EduMIPS64|Version:|JRE version|OS:|[A-Z][a-z]{2} [0-9]+, 20)|^INFO:' <<<"$out"
  if grep -q 'fatal error' <<<"$out"; then
    echo "Your program crashed: it used memory outside the .data section."
  elif ! grep -q -E 'errors found|Unable to' <<<"$out"; then
    echo "The program did not finish within 60 s (an endless loop?)."
  fi
  exit 1
fi
# The word at label s, as a signed 64-bit decimal.
hex=$(sed -n 's/.*VALUE \([0-9A-F]*\), LABEL  s,.*/\1/p' <<<"$out")
echo "forwarding: $val"
echo "cycles: $cycles"
[ -n "$hex" ] && echo "s: $(( 16#$hex ))"
exit 0

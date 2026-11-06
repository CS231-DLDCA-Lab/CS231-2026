#!/usr/bin/env bash
# Apply the Task 3 patch to a ChampSim folder.
#   ./task3/apply_patch.sh ~/Desktop/ChampSim
# The patch gives every packet a dirty bit (inc/block.h, src/cache.cc) and makes
# main.cc print how many L2C lines are also in the LLC. Then edit src/cache.cc.
set -e
dir=${1:?usage: $0 <ChampSim folder>}
patch_file="$(cd "$(dirname "$0")" && pwd)/task3.patch"

if patch -p1 -R --dry-run -s -f -d "$dir" < "$patch_file" > /dev/null 2>&1; then
    echo "$dir already has the Task 3 patch"
    exit 0
fi
patch -p1 -s -d "$dir" < "$patch_file"
echo "patched $dir"

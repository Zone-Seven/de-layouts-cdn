#!/usr/bin/env bash
# Purge jsDelivr's edge cache for published files. jsDelivr caches @main URLs
# for 12 hours, so without a purge a newly published demo would not appear in
# the plugin's browse index for up to 12 hours. layout.json fetches carry a
# ?v=<hash> cache-buster, so index.json (and changed thumbnails) are what need
# purging.
#
# Usage:
#   bash scripts/purge-cdn.sh                      # purge layouts/index.json
#   bash scripts/purge-cdn.sh <before-sha> <after-sha>   # + every file changed in that range
set -euo pipefail
cd "$(dirname "$0")/.."

CDN_PREFIX="https://purge.jsdelivr.net/gh/Zone-Seven/de-layouts-cdn@main"
MAX_FILES=200

paths=( "layouts/index.json" )

if [[ $# -eq 2 && "$1" != "0000000000000000000000000000000000000000" ]] && git cat-file -e "$1" 2>/dev/null; then
	while IFS= read -r changed; do
		[[ -n "$changed" && "$changed" != "layouts/index.json" ]] && paths+=( "$changed" )
	done < <( git diff --name-only "$1" "$2" -- layouts | head -n "$MAX_FILES" )
fi

failed=0
for path in "${paths[@]}"; do
	if curl -fsS --max-time 30 "$CDN_PREFIX/$path" -o /dev/null; then
		echo "purged: $path"
	else
		echo "purge FAILED: $path"
		failed=1
	fi
done
exit $failed

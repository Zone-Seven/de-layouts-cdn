#!/usr/bin/env bash
# Fail if any file under layouts/ exceeds jsDelivr's 20 MB per-file limit —
# the CDN refuses such files (HTTP 403), so the plugin import would break.
# Warns from 15 MB so growth is visible before it becomes a failure.
# Run locally before pushing: bash scripts/check-sizes.sh
set -euo pipefail
cd "$(dirname "$0")/.."

LIMIT=$(( 20 * 1024 * 1024 ))
WARN=$(( 15 * 1024 * 1024 ))
status=0

while IFS= read -r -d '' file; do
	size=$( wc -c < "$file" )
	if (( size > LIMIT )); then
		echo "ERROR: $file is $(( size / 1048576 )) MB — over the 20 MB jsDelivr limit, the CDN will not serve it"
		status=1
	elif (( size > WARN )); then
		echo "WARN:  $file is $(( size / 1048576 )) MB — approaching the 20 MB jsDelivr limit"
	fi
done < <( find layouts -type f -print0 )

if (( status == 0 )); then
	echo "check-sizes: OK — no file over 20 MB"
fi
exit $status

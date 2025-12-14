#!/usr/bin/env bash
set -euo pipefail

# Simple test script to POST to /entry/submit
# Usage: ./scripts/test_post_entry.sh [URL]
# Default URL: http://localhost:3000

URL=${1:-http://localhost:3000}

echo "Posting test data to ${URL}/entry/submit"

curl -sS -D - \
  -X POST "${URL}/entry/submit" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "datepicker=2025/12/14" \
  --data-urlencode "sid=1" \
  --data-urlencode "kid=1" \
  --data-urlencode "mode=insert" \
  --data-urlencode "fnaoh1=1.000" \
  --data-urlencode "fnaoh2=1.000" \
  --data-urlencode "fedta=1.000" \
  --data-urlencode "fi=1.000" \
  --data-urlencode "fhcl=1.000" \
  --data-urlencode "submit=submit" -o /tmp/test_post_entry_response.html

echo "Response saved to /tmp/test_post_entry_response.html"
echo "---- Response head ----"
sed -n '1,120p' /tmp/test_post_entry_response.html || true

exit 0

#!/usr/bin/env bash
# Verify a deployed service responds 200 OK on /health.
#
# Usage: ./scripts/smoke_test.sh http://my-alb-123.us-east-1.elb.amazonaws.com
set -euo pipefail

BASE_URL="${1:?usage: smoke_test.sh <base-url>}"
CODE="$(curl -fsS -o /dev/null -w '%{http_code}' "${BASE_URL%/}/health")"

echo "GET ${BASE_URL%/}/health -> ${CODE}"
if [ "$CODE" != "200" ]; then
  echo "Health check FAILED" >&2
  exit 1
fi
echo "Health check OK"

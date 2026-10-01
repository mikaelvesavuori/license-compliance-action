#!/bin/bash -l

set -o pipefail

ORANGE='\033[0;33m'
NC='\033[0m'
echo "${ORANGE}NOTE: Since this scans package.json, the action will NOT RUN unless you have package.json present in your root folder.\n${NC}"

RANDOM_STRING="dba902ac-2531-41" # Random bit from Mockachino

# Resolve the path to script.sh so the violation test can run from a temp dir
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/script.sh"

# Testing default settings
ALLOW_LICENSES="MIT;ISC;0BSD;BSD-2-Clause;BSD-3-Clause;Apache-2.0"
NESTED_FIELD=""
EXCLUDE_PATTERN=""

sh script.sh "$ALLOW_LICENSES" "$NESTED_FIELD" "$EXCLUDE_PATTERN"

# Testing online version
ALLOW_LICENSES="https://www.mockachino.com/$RANDOM_STRING/licenses"
NESTED_FIELD="licenseString"
EXCLUDE_PATTERN=""

sh script.sh "$ALLOW_LICENSES" "$NESTED_FIELD" "$EXCLUDE_PATTERN"

# Testing violation detection: a non-compliant package MUST make the
# action fail with a non-zero exit code. This guards against the
# regression where script.sh always exited 0 (see issue: broken since
# v1.0.1). The test runs in a throwaway dir with its own package.json so
# it does not depend on the repo root having one.
echo ""
echo "--- Testing violation detection (expect non-zero exit) ---"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# yaml@2.2.2 is ISC-licensed; allowing only "0BSD" guarantees a violation.
( cd "$TMP_DIR" && npm init -y >/dev/null 2>&1 && npm install --save-exact yaml@2.2.2 >/dev/null 2>&1 )
if [ ! -f "$TMP_DIR/package.json" ]; then
  echo "SKIP: could not set up package.json in temp dir (npm unavailable?)"
  exit 0
fi

( cd "$TMP_DIR" && sh "$SCRIPT_PATH" "0BSD" "" "" ) >"$TMP_DIR/out.log" 2>&1
VIOLATION_EXIT=$?

if [ "$VIOLATION_EXIT" -ne 0 ]; then
  echo "PASS: violation correctly produced non-zero exit ($VIOLATION_EXIT)"
else
  echo "FAIL: violation did NOT produce a non-zero exit (got 0)"
  echo "----- script output -----"
  cat "$TMP_DIR/out.log"
  echo "-------------------------"
  exit 1
fi

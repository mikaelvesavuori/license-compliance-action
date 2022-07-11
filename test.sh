#!/bin/bash -l

set -o pipefail

RANDOM_STRING="dba902ac-2531-41" # Random bit from Mockachino

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

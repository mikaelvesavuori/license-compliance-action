#!/bin/bash -l

#
# license-compliance
# https://github.com/mikaelvesavuori/license-compliance-action
#
# This is a wrapper on top of `license-compliance`
# (https://www.npmjs.com/package/license-compliance)
# to help check licenses of production dependencies during CI.
#

set -o pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Set user inputs
LICENSES="$1"
echo "LICENSES is: ${BLUE}$LICENSES${NC}"

NESTED_FIELD="$2"
echo "NESTED_FIELD is: ${BLUE}$NESTED_FIELD${NC}"

EXCLUDE_PATTERN="$3"
echo "EXCLUDE_PATTERN is: ${BLUE}$EXCLUDE_PATTERN${NC}"

# This value will contain the final license string
LICENSE_STRING="$LICENSES"

main() {
  if [ -f "package.json" ]; then
    installNodeDependencies
    getLicenseStringFromUrl
    runLicenseComplianceSummary
    runLicenseCompliance
  fi
}

installNodeDependencies() {
  echo "${GREEN}Installing dependencies...${NC}\n"
  npm install license-compliance -D
}

getLicenseStringFromUrl() {
  # Thanks to contributors at https://stackoverflow.com/questions/3183444/check-for-valid-link-url for ideas.
  REGEX='(https)://'
  if [[ $LICENSES =~ $REGEX ]]; then
    echo "${GREEN}Getting license string from provided URL: ${BLUE}$LICENSES${NC}"
    LICENSE_RESPONSE=$(curl -X GET "$LICENSES" --silent)
    if [[ $NESTED_FIELD ]]; then
      LICENSE_STRING=$(echo "$LICENSE_RESPONSE" | jq ".$NESTED_FIELD" -r)
      echo "${GREEN}Licenses picked up: ${BLUE}$LICENSE_STRING${NC}"
    else
      LICENSE_STRING=$(echo "$LICENSE_RESPONSE" | jq "." -r)
    fi
  fi
}

runLicenseComplianceSummary() {
  echo "${GREEN}Summary of all licenses:${NC}"
  npx license-compliance
}

runLicenseCompliance() {
  echo "${GREEN}Checking compliance:${NC}"
  npx license-compliance --production --allow "$LICENSE_STRING" --exclude "$EXCLUDE_PATTERN"

  echo "" # Just create some extra space

  EXIT_CODE=$(echo $?)
  exit $EXIT_CODE
}

main "$@"
exit

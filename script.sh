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

# Set user inputs
LICENSES="$1"
echo "LICENSES is: $LICENSES"

NESTED_FIELD="$2"
echo "NESTED_FIELD is: $NESTED_FIELD"

EXCLUDE_PATTERN="$3"
echo "EXCLUDE_PATTERN is: $EXCLUDE_PATTERN"

# This value will contain the final license string
LICENSE_STRING="$LICENSES"

main() {
  if [ -f "package.json" ]; then
    installNodeDependencies
    getLicenseStringFromUrl
    runLicenseCompliance
  fi
}

installNodeDependencies() {
  echo "Installing dependencies..."
  npm install license-compliance -D
}

getLicenseStringFromUrl() {
  # Thanks to contributors at https://stackoverflow.com/questions/3183444/check-for-valid-link-url for ideas.
  REGEX='(https)://'
  if [[ $LICENSES =~ $REGEX ]]; then
    echo "Getting license string from provided URL: $LICENSES"
    LICENSE_RESPONSE=$(curl -X GET "$LICENSES" --silent)
    if [[ $NESTED_FIELD ]]; then
      LICENSE_STRING=$(echo "$LICENSE_RESPONSE" | jq ".$NESTED_FIELD" -r)
      echo "Licenses picked up: $LICENSE_STRING"
    else
      LICENSE_STRING=$(echo "$LICENSE_RESPONSE" | jq "." -r)
    fi
  fi
}

runLicenseCompliance() {
  npx license-compliance --production --allow "$LICENSE_STRING" --exclude "$EXCLUDE_PATTERN"
}

main "$@"
exit

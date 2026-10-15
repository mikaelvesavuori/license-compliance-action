#!/bin/bash -l

#
# license-compliance
# https://github.com/mikaelvesavuori/license-compliance-action
#
# This is a wrapper on top of `license-compliance`
# (https://www.npmjs.com/package/license-compliance)
# to help check licenses of production dependencies during CI.
#

set -eo pipefail

# Set user inputs
LICENSES="$1"
echo "LICENSES is: $LICENSES"

NESTED_FIELD="$2"
echo "NESTED_FIELD is: $NESTED_FIELD"

EXCLUDE_PATTERN="$3"
echo "EXCLUDE_PATTERN is: $EXCLUDE_PATTERN"

DIRECT="$4"
echo "DIRECT is: $DIRECT"

# This value will contain the final license string
LICENSE_STRING="$LICENSES"

# Allow empty value (script invoked directly) and validate
if [ -z "$DIRECT" ]; then
  DIRECT='false'
fi
case "$DIRECT" in
  true|false) ;;
  *) echo "direct must be true or false"; exit 1;;
esac

# Shared dependency arguments used by both the summary and enforcement runs
DEPENDENCY_ARGS=(--production)
if [ "$DIRECT" = "true" ]; then
  DEPENDENCY_ARGS+=(--direct)
fi

main() {
  if [ -f "package.json" ]; then
    installNodeDependencies
    getLicenseStringFromUrl
    runLicenseComplianceSummary
    runLicenseCompliance
  fi
}

installNodeDependencies() {
  echo "Installing dependencies...\n"
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

runLicenseComplianceSummary() {
  echo "Summary of all licenses:"
  npx license-compliance "${DEPENDENCY_ARGS[@]}"
}

runLicenseCompliance() {
  echo "Checking compliance:"
  if npx license-compliance "${DEPENDENCY_ARGS[@]}" --allow "$LICENSE_STRING" --exclude "$EXCLUDE_PATTERN"; then
    echo ""
    echo "License scan complete!"
    echo ""
  else
    EXIT_CODE=$?
    echo ""
    echo "License scan failed! Non-compliant packages found."
    echo ""
    exit "$EXIT_CODE"
  fi
}

main "$@"
exit

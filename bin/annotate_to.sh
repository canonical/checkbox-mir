#!/bin/bash
set -euo pipefail

ARTEFACTS=${PLAINBOX_SESSION_SHARE}/artefacts.json
curl --silent -X 'GET' \
  'https://test-observer-api.canonical.com/v1/artefacts?family=snap' \
  -H 'accept: application/json' \
  > ${ARTEFACTS}

print_to_check() {
  artefact=( $( jq -r \
    --arg SNAP "$SNAP" \
    --arg TRACK "$TRACK" \
    --arg RISK "$RISK" \
    '.[] | select(.name==$SNAP and .track==$TRACK and .stage==$RISK) | [.id, .version] | @tsv' \
    ${ARTEFACTS}
  ) )

  if [ -n "${artefact:-}" ]; then
    echo version: ${artefact[1]}
    echo to_check: Verify the results at https://test-observer.canonical.com/#/snaps/${artefact[0]}
  else
    echo version:
    echo to_check:
  fi
}

while IFS='' read line; do
  if [ "-z" "$line" ]; then
    print_to_check
  elif [[ "$line" =~ ^snap:\ (.*)$ ]]; then
    SNAP=${BASH_REMATCH[1]}
  elif [[ "$line" =~ ^track:\ (.*)$ ]]; then
    TRACK=${BASH_REMATCH[1]}
  elif [[ "$line" =~ ^risk:\ (.*)$ ]]; then
    RISK=${BASH_REMATCH[1]}
  fi
  echo "$line"
done
print_to_check

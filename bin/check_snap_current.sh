#!/bin/bash

set -eu

INSTANCE=$1
# Strip instance name
SNAP=${1/_*/}
TRACK=$2
RISK=$3

ARCH=$( dpkg-architecture -qDEB_HOST_ARCH )
CURRENT_REV=$(
    curl -s -H "Snap-Device-Series: 16" --unix-socket /run/snapd.socket http://localhost/v2/snaps/${INSTANCE} \
    | jq -r '.result.revision' \
    || exit $$
)
STORE_REV=$(
    curl -s -H "Snap-Device-Series: 16" "https://api.snapcraft.io/v2/snaps/info/${SNAP}" \
    | jq -r --arg TRACK "${TRACK}" --arg RISK "${RISK}" --arg ARCH "${ARCH}" \
      '."channel-map" | .[] | select(.channel.track==$TRACK and .channel.risk==$RISK and .channel.architecture==$ARCH) | .revision' \
    || exit $$
)

set -x

[ "$CURRENT_REV" = "$STORE_REV" ] || exit $?

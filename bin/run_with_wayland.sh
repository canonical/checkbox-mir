#!/bin/bash

set -euo pipefail

OUTPUT=$( mktemp )
export WAYLAND_DISPLAY=wayland-${RANDOM}

[ -n "${XDG_RUNTIME_DIR:-}" ] || ( echo "ERROR: XDG_RUNTIME_DIR unset"; exit 3 )

# Mangle the XDG runtime path
mkdir -p $XDG_RUNTIME_DIR/..
REAL_RUNTIME_DIR=$( readlink -f $XDG_RUNTIME_DIR/.. )

# Default to an error
echo 128 > $OUTPUT.status

cleanup() {
    # Run through cleanup despite errors
    set +euo pipefail
    STATUS=$( cat $OUTPUT.status )
    rm $OUTPUT*
    for pid in $( jobs -p ); do
        kill $pid
        timeout 10 tail --pid=$pid -f /dev/null || kill -9 $pid
        timeout 10 tail --pid=$pid -f /dev/null || echo "WARNING: Failed to clean up PID $pid"
    done
    exit $STATUS
}

trap cleanup EXIT

env XDG_RUNTIME_DIR=$REAL_RUNTIME_DIR mir_demo_server &

timeout 10 bash -c "until [ -S $REAL_RUNTIME_DIR/$WAYLAND_DISPLAY ]; do sleep 1; done" \
  || ( echo "ERROR: Wayland failed to start"; exit 2 )

timeout 10 "$@" \
  && echo 0 > $OUTPUT.status \
  || echo $? > $OUTPUT.status

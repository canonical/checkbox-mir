#!/bin/bash

set -euo pipefail
OUTPUT=$( mktemp )
export DISPLAYNO=99
export DISPLAY=:$DISPLAYNO

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

Xorg $DISPLAY &

timeout 10 bash -c "until [ -S /tmp/.X11-unix/X$DISPLAYNO ]; do sleep 1; done" \
  || ( echo "ERROR: Xorg failed to start"; exit 2 )

timeout 10 "$@" \
  && echo 0 > $OUTPUT.status \
  || echo $? > $OUTPUT.status

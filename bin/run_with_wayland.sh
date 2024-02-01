#!/bin/bash

set -euo pipefail

! PARSED=$(getopt --options=s:t: --longoptions=server:,timeout: --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"

SERVER=mir_demo_server
TIMEOUT=10
while true; do
    case "$1" in
        -s|--server)
            SERVER="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Usage:"
            echo "  $0 [--server <server>] [--timeout <timeout>] -- <command> [<arg> ...]"
            exit 3
            ;;
    esac
done



OUTPUT=$( mktemp )
export WAYLAND_DISPLAY=wayland-${RANDOM}

REAL_RUNTIME_DIR=/run/user/$UID
mkdir -p $REAL_RUNTIME_DIR

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

env XDG_RUNTIME_DIR=$REAL_RUNTIME_DIR $SERVER &
SERVER_PID=$!

timeout 10 bash -c "until [ -S $REAL_RUNTIME_DIR/$WAYLAND_DISPLAY ]; do ps -p $SERVER_PID > /dev/null || exit 1; sleep 1; done" \
  || ( echo "ERROR: ${SERVER} failed to start"; exit 3 )

export MIR_SERVER_WAYLAND_HOST=$WAYLAND_DISPLAY

timeout $TIMEOUT "$@" \
  && echo 0 > $OUTPUT.status \
  || echo $? > $OUTPUT.status

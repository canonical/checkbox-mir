#!/bin/bash

set -eu

cd $( dirname $( python3 -c 'import mir_ci; print(mir_ci.__file__)' ) )

unset XKB_CONFIG_ROOT
export XDG_RUNTIME_DIR=/run/user/$UID

exec python3 \
    -m pytest \
    -o cache_dir=/tmp/pytest-cache \
    -o filterwarnings='ignore:.*missing tools.*' \
    "$@"

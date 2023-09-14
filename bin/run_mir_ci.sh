#!/bin/bash

cd $( dirname $( python3 -c 'import mir_ci; print(mir_ci.__file__)' ) )

unset XKB_CONFIG_ROOT
export XDG_RUNTIME_DIR=$( dirname $XDG_RUNTIME_DIR )

exec python3 -m pytest "$@" -o cache_dir=$TMPDIR/pytest-cache

#!/bin/bash

cd $( dirname $( python3 -c 'import mir_ci; print(mir_ci.__file__)' ) )

exec python3 -m pytest "$@" -o cache_dir=$TMPDIR/pytest-cache

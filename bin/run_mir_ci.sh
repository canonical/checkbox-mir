#!/bin/bash

set -eu

MIR_CI_ROOT=$( dirname $( python3 -c 'import mir_ci; print(mir_ci.__file__)' ) )
cd $MIR_CI_ROOT

unset XKB_CONFIG_ROOT
export XDG_RUNTIME_DIR=/run/user/$UID
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${SNAP}/usr/lib/${SNAP_LAUNCHER_ARCH_TRIPLET}/blas:${SNAP}/usr/lib/${SNAP_LAUNCHER_ARCH_TRIPLET}/lapack

exec python3 \
    -m pytest \
    --rootdir=$MIR_CI_ROOT \
    --config-file=$MIR_CI_ROOT/pytest.ini \
    -o cache_dir=/tmp/pytest-cache \
    -o filterwarnings='ignore:.*missing tools.*' \
    "$@"

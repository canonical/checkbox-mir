#!/bin/sh

set -xeu

exec env -i \
  DISPLAY=$DISPLAY \
  HOME=$HOME \
  PATH=/usr/sbin:/usr/bin:/snap/bin \
  WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  XDG_RUNTIME_DIR=/run/user/$( id -u ) \
  "$@"

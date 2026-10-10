#!/bin/bash

shopt -s nullglob
APPIMAGES=(/opt/wootility/*AppImage)
if (( ${#APPIMAGES[@]} != 1 )); then
    echo 'Expected one AppImage in /opt/wootility/.' >&2
    exit 1
fi
WOOTILITY=${APPIMAGES[0]}

exec "${WOOTILITY}" "$@" 2>&1 >/dev/null

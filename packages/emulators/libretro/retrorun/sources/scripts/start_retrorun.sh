#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

CORE="$1"
ROM="$2"
PLATFORM="$3"
export DEVICE_NAME="${HW_DEVICE}"

case "$CORE" in
    snes9x|snes9x2010|beetle_supafaust)
        EXPECTED_EXT="smc|fig|sfc|swc"
        ;;
esac

if [[ -n "$EXPECTED_EXT" && "$ROM" =~ \.(zip|7z)$ ]]; then
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    unzip -o "$ROM" -d "$TMPDIR" >/dev/null

    ROM=$(find "$TMPDIR" -type f | grep -Ei "\.(${EXPECTED_EXT})$" | head -n 1)

    if [[ -z "$ROM" ]]; then
        echo "No expected ROM file found in archive for core $CORE"
        exit 1
    fi
fi

# Change to virtual terminal 2 so Sway releases the DRM device
chvt 2

/usr/bin/retrorun -c /etc/retrorun/retrorun.cfg \
    -s "/storage/roms/${PLATFORM}" \
    "/usr/lib/libretro/${CORE}_libretro.so" \
    "${ROM}" \
    > /var/log/retrorun_stdout.log \
    2> /var/log/retrorun_stderr.log

# Change back to virtual terminal 1
chvt 1

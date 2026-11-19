#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "bigpemu"

# libmali GPU driver needs gl4es
if [ -x "/usr/bin/gpudriver" ] && [ $(/usr/bin/gpudriver) = "libmali" ]; then
  export LD_PRELOAD=/usr/lib/gl4es/libGL.so.1
fi

sway_fullscreen "bigpemu" &

/usr/share/bigpemu/bigpemu >/dev/null 2>&1

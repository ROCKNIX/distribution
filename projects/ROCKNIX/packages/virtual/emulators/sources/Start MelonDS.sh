
#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 melonDS"

sway_fullscreen "melonDS" "class" &

# QT platform - default to xcb
export QT_QPA_PLATFORM=xcb

# QT platform - some device / driver combinations need wayland
case ${HW_DEVICE} in
    RK3566|RK3588|S922X)
        [[ $(/usr/bin/gpudriver) == "libmali" ]] && export QT_QPA_PLATFORM=wayland
    ;;
esac

/usr/bin/melonDS

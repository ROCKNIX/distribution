#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 FEXConfig"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls
if [ ! -d "/storage/.config/fex-emu" ]; then
    cp -r "/usr/config/fex-emu" "/storage/.config/"
fi
${GPTOKEYB} fexconfig -c /storage/.config/fex-emu/gptk/fexconfig.gptk &
swaymsg for_window [app_id="FEXConfig"] fullscreen enable
/usr/bin/FEXConfig
kill -9 $(pidof gptokeyb)
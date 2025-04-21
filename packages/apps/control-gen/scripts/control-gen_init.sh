#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

#Check if gptokeyb exists in .config
if [ ! -d "/storage/.config/gptokeyb" ]; then
    mkdir -p "/storage/.config/gptokeyb"
fi

#Link gamecontrollerdb.txt
ln -sf /usr/config/SDL-GameControllerDB/gamecontrollerdb.txt /storage/.config/gptokeyb/gamecontrollerdb.txt

#Link gptokeyb
ln -sf /usr/bin/gptokeyb /storage/.config/gptokeyb/gptokeyb

#Run control-gen
/usr/bin/control-gen >  /storage/.config/gptokeyb/control.ini

#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

source /etc/profile

#Check if ARMSX2 exists in .config
if [ ! -d "/storage/.config/ARMSX2" ]; then
    mkdir -p "/storage/.config/ARMSX2"
        cp -r "/usr/config/ARMSX2" "/storage/.config/"
fi

#Make ARMSX2 bios folder
if [ ! -d "/storage/roms/bios/armsx2" ]; then
    mkdir -p "/storage/roms/bios/armsx2"
fi

set_kill set "armsx2-qt"

#Set OpenGL 3.3 on panfrost
  export MESA_GL_VERSION_OVERRIDE=3.3
  export MESA_GLSL_VERSION_OVERRIDE=330

#Set QT enviornment to wayland
  export QT_QPA_PLATFORM=wayland

sway_fullscreen "armsx2-qt" &

/usr/share/armsx2-sa/armsx2-qt >/dev/null 2>&1

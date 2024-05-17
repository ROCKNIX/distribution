#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

if [[ "${UI_SERVICE}" =~ "weston.service"|"*sway*" ]]; then
  if [[ $(glxinfo | grep -i "opengl renderer") =~ "Panfrost" ]]; then
    if [[ "${HW_DEVICE}" =~ "RK3399"|"RK3588"|"S922X" ]]; then
      #Remove gl4es libs on devices that support OpenGL and sed any port that references it
      rm -rf /storage/roms/ports/*/lib*/libEGL*
      rm -rf /storage/roms/ports/*/lib*/libGL*
      for port in /storage/roms/ports/*.sh; do
        if  grep -q SDL_VIDEO_GL_DRIVER "$port"; then
          sed -i '/^export SDL_VIDEO_GL_DRIVER/c\#export SDL_VIDEO_GL_DRIVER' "$port"
          sed -i '/^export SDL_VIDEO_EGL_DRIVER/c\#export SDL_VIDEO_EGL_DRIVER' "$port"
          echo Fixing: "$port";
        fi
      done;
    fi

    #Remove S922X fix if exists
    for port in /storage/roms/ports/*.sh; do
      sed -i '/get_controls && export/c\get_controls' "$port"
      echo Fixing: "$port";
    done;
  else
    case "${QUIRK_DEVICE}" in
      "Hardkernel ODROID-GO-Ultra"|"Powkiddy RGB10 MAX 3 Pro"|"Hardkernel ODROID-N2*")
      #Fixing ports on S922X, exclude FNA games
      for port in /storage/roms/ports/*.sh; do
        if ! grep -q FNA "$port"; then
          sed -i '/get_controls/c\get_controls && export SDL_VIDEO_GL_DRIVER=/usr/lib/egl/libGL.so.1 SDL_VIDEO_EGL_DRIVER=/usr/lib/egl/libEGL.so.1' "$port"
          echo Fixing: "$port";
        fi
      done;
    ;;
    esac
  fi
fi

#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# Source predefined functions and variables
. /etc/profile
set_kill set "-9 kronos"

ROM_DIR="/storage/roms/saturn/kronos"
CONFIG_DIR="/storage/.config/kronos/qt"
SOURCE_DIR="/usr/config/kronos/qt"
BIOS_BACKUP="/storage/roms/bios/kronos"

if [ ! -d "${ROM_DIR}" ]
then
  mkdir -p "${ROM_DIR}"
fi

if [ ! -d "${BIOS_BACKUP}" ]
then
  mkdir -p "${BIOS_BACKUP}"
fi

if [ ! -d "${CONFIG_DIR}" ]
then
  mkdir -p "${CONFIG_DIR}"
fi

if [ ! -e "${CONFIG_DIR}/kronos.ini" ]
then
  cp -f ${SOURCE_DIR}/kronos.ini ${CONFIG_DIR}
fi

BIOS=""
GAME=$(echo "${1}"| sed "s#^/.*/##")
USE_BIOS=$(get_setting use_hlebios saturn "${GAME}")
if [ ! "${USE_BIOS}" = 1 ]
then
  USE_BIOS=$(get_setting use_hlebios saturn)
fi

USE_SKIP=$(get_setting use_autoskip saturn "${GAME}")
if [ "$USE_SKIP" = 1 ]
then
  AUTOSKIP="-autoframeskip 1"
fi

VIDEO_DRIVER=$(get_setting video_driver saturn "${GAME}")
case ${VIDEO_DRIVER} in
  opengl)
    sed -i 's~Video\\VideoCore=.*$~Video\\VideoCore=1~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    #Software
    sed -i 's~Video\\VideoCore=.*$~Video\\VideoCore=2~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

AUDIO_DRIVER=$(get_setting audio_driver saturn "${GAME}")
case ${AUDIO_DRIVER} in
  openal)
    sed -i 's~Sound\\SoundCore=.*$~Sound\\SoundCore=4~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    #SDL
    sed -i 's~Sound\\SoundCore=.*$~Sound\\SoundCore=1~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

SHOW_FPS=$(get_setting show_fps saturn "${GAME}")
case ${SHOW_FPS} in
  1)
    sed -i 's~General\\ShowFPS=.*$~General\\ShowFPS=true~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    sed -i 's~General\\ShowFPS=.*$~General\\ShowFPS=false~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

USE_VSYNC=$(get_setting use_vsync saturn "${GAME}")
case ${USE_VSYNC} in
  1)
    sed -i 's~General\\EnableVSync=.*$~General\\EnableVSync=true~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    sed -i 's~General\\EnableVSync=.*$~General\\EnableVSync=false~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

COMPUTE_SHADER=$(get_setting gpu_rgb saturn "${GAME}")
case ${COMPUTE_SHADER} in
  1)
    #gpu
    sed -i 's~Video\\compute_shader_mode=.*$~Video\\compute_shader_mode=1~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    #cpu
    sed -i 's~Video\\compute_shader_mode=.*$~Video\\compute_shader_mode=1~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

TESSELLATION=$(get_setting tessellation saturn "${GAME}")
case ${TESSELLATION} in
  gpu)
    sed -i 's~Video\\polygon_generation_mode=.*$~Video\\polygon_generation_mode=2~g' ${CONFIG_DIR}/kronos.ini
  ;;
  *)
    #cpu
    sed -i 's~Video\\polygon_generation_mode=.*$~Video\\polygon_generation_mode=1~g' ${CONFIG_DIR}/kronos.ini
  ;;
esac

#Get the number of active threads
ACTIVE_THREADS=$(grep processor /proc/cpuinfo  | wc -l)
sed -i 's~General\\NumThreads=.*$~General\\NumThreads='${ACTIVE_THREADS}'~g' ${CONFIG_DIR}/kronos.ini

kronos -a -f  -i "${1}" ${BIOS} ${AUTOSKIP} >>/var/log/exec.log 2>&1 ||:

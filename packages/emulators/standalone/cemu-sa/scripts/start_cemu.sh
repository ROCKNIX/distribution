#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# Source environment variables
. /etc/profile

# Ensure we're using pulseaudio
export SDL_AUDIODRIVER=pulseaudio
set_kill set "-9 cemu"

if [ -z "${PASINK}" ]
then
  PASINK=$(pactl info | grep 'Default Sink:' | cut -d ' ' -f 3)
fi

# Set up mime db
mkdir -p /storage/.local/share/mime/packages
cp -rf /usr/share/mime/packages/* /storage/.local/share/mime/packages
update-mime-database /storage/.local/share/mime

# Set common paths
CEMU_CONFIG_ROOT="/storage/.config/Cemu"
CEMU_CACHE_LOG="${CEMU_CONFIG_ROOT}/share/log.txt"
CEMU_VAR_LOG="/var/log/Cemu.log"
CEMU_HOME_CONFIG="${CEMU_CONFIG_ROOT}/share"
CEMU_HOME_LOCAL="/storage/.local/share/Cemu"

# create link to config directory
if [ ! -d ${CEMU_HOME_CONFIG} ]; then
  mkdir -p ${CEMU_HOME_CONFIG}
  echo created ${CEMU_HOME_CONFIG}
fi

if [ -d ${CEMU_HOME_LOCAL} ] && [ ! -L ${CEMU_HOME_LOCAL} ]; then
    cp -rf ${CEMU_HOME_LOCAL}/* ${CEMU_HOME_CONFIG}
    rm -rf ${CEMU_HOME_LOCAL}
    echo moved ${CEMU_HOME_LOCAL} to ${CEMU_HOME_CONFIG}
fi

if [ ! -L ${CEMU_HOME_LOCAL} ]; then
  ln -sf ${CEMU_HOME_CONFIG} ${CEMU_HOME_LOCAL}
  echo created symlink from ${CEMU_HOME_CONFIG} to ${CEMU_HOME_LOCAL}
fi

# Create symlink to logfile
if [ ! -L ${CEMU_VAR_LOG} ]; then
  ln -sf ${CEMU_CACHE_LOG} ${CEMU_VAR_LOG}
fi

# Make sure CEMU settings exist, and set the audio output.
if [ ! -f "${CEMU_CONFIG_ROOT}/settings.xml" ]
then
  cp -f /usr/config/Cemu/settings.xml ${CEMU_CONFIG_ROOT}/settings.xml
fi

# Make sure the basic controller profiles exist.
if [ ! -d "${CEMU_CONFIG_ROOT}/controllerProfiles" ]
then
  mkdir -p ${CEMU_CONFIG_ROOT}/controllerProfiles
fi

FILE=$(echo $1 | sed "s#^/.*/##g")
ONLINE=$(get_setting online_enabled wiiu "${FILE}")
FPS=$(get_setting show_fps wiiu "${FILE}")
CON=$(get_setting wiiu_controller_profile wiiu "${FILE}")
RENDERER=$(get_setting graphics_backend wiiu "${FILE}")
BACKEND=$(get_setting gdk_backend wiiu "${FILE}")

if [ -z "${FPS}" ]
then
  FPS="0"
fi

# Assume Vulkan
case ${RENDERER} in
  opengl)
    RENDERER=0
  ;;
  *)
    RENDERER=1
  ;;
esac

case ${BACKEND} in
  x11)
    export GDK_BACKEND=x11
  ;;
  *)
    export GDK_BACKEND=wayland
  ;;
esac

case ${CON} in
  "Wii U Pro Controller")
     CONFILE="wii_u_pro_controller.xml"
     CON="Wii U Pro Controller"
  ;;
  *)
     ### Break these out when possible.
     ### "Wii U GamePad"|"Wii U Classic Controller"|"Wiimote"
     CONFILE="wii_u_gamepad.xml"
     CON="Wii U GamePad"
  ;;
esac

for CONTROLLER in /usr/config/Cemu/controllerProfiles/*
do
  LOCALFILE="$(basename ${CONTROLLER})"
  if [ "${CONFILE}" = "${LOCALFILE}" ]
  then
      cp "${CONTROLLER}" "${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml"
  fi
done

UUID0="0_$(control-gen | awk 'BEGIN {FS="\""} /^DEVICE/ {print $2;exit}')"
CONTROLLER0=$(grep -b4 js0 /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')

xmlstarlet ed --inplace -u "//Account/OnlineEnabled" -v "${ONLINE}" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//Overlay/Position" -v "${FPS}" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//fullscreen" -v "true" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//Audio/TVDevice" -v "${PASINK}" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//Graphic/api" -v "${RENDERER}" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//emulated_controller/type" -v "${CON}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml
xmlstarlet ed --inplace -u "//emulated_controller/controller/uuid" -v "${UUID0}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml
xmlstarlet ed --inplace -u "//emulated_controller/controller/display_name" -v "${CONTROLLER0}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml

# Run the emulator
cemu -g "$@"

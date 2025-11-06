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
CEMU_HOME_ONLINE="${CEMU_HOME_CONFIG}/online"
CEMU_HOME_MLC01="${CEMU_HOME_CONFIG}/mlc01"
CEMU_HOME_KEYS="${CEMU_HOME_CONFIG}/keys"
CEMU_BIOS="/storage/roms/bios/cemu"

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

# create symlink to online directory
mkdir -p "${CEMU_BIOS}/online"
if [ -d ${CEMU_HOME_ONLINE} ] && [ ! -L ${CEMU_HOME_ONLINE} ]; then
    mv ${CEMU_HOME_ONLINE}/* ${CEMU_BIOS}/online
    rm -rf ${CEMU_HOME_ONLINE}
    echo moved ${CEMU_HOME_ONLINE} to ${CEMU_BIOS}/online
fi

if [ ! -L ${CEMU_HOME_ONLINE} ]; then
  ln -sf ${CEMU_BIOS}/online ${CEMU_HOME_ONLINE}
  echo created symlink from ${CEMU_HOME_ONLINE} to ${CEMU_BIOS}/online
fi

# create symlink to mlc01 directory
mkdir -p "${CEMU_BIOS}/mlc01"
if [ -d ${CEMU_HOME_MLC01} ] && [ ! -L ${CEMU_HOME_MLC01} ]; then
    mv ${CEMU_HOME_MLC01}/* ${CEMU_BIOS}/mlc01
    rm -rf ${CEMU_HOME_MLC01}
    echo moved ${CEMU_HOME_MLC01} to ${CEMU_BIOS}/mlc01
fi

if [ ! -L ${CEMU_HOME_MLC01} ]; then
  ln -sf ${CEMU_BIOS}/mlc01 ${CEMU_HOME_MLC01}
  echo created symlink from ${CEMU_HOME_MLC01} to ${CEMU_BIOS}/mlc01
fi

# create symlink to keys directory
mkdir -p "${CEMU_BIOS}/keys"
if [ -d ${CEMU_HOME_KEYS} ] && [ ! -L ${CEMU_HOME_KEYS} ]; then
    mv ${CEMU_HOME_KEYS}/* ${CEMU_BIOS}/keys
    rm -rf ${CEMU_HOME_KEYS}
    echo moved ${CEMU_HOME_KEYS} to ${CEMU_BIOS}/keys
fi

if [ ! -L ${CEMU_HOME_KEYS} ]; then
  ln -sf ${CEMU_BIOS}/keys ${CEMU_HOME_KEYS}
  echo created symlink from ${CEMU_HOME_KEYS} to ${CEMU_BIOS}/keys
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
  cp -R /usr/config/Cemu/controllerProfiles ${CEMU_CONFIG_ROOT}/
fi

FILE=$(echo $1 | sed "s#^/.*/##g")
CON=$(get_setting wiiu_controller_profile wiiu "${FILE}")
CON_LAYOUT=$(get_setting wiiu_controller_layout wiiu "${FILE}")
ONLINE=$(get_setting online_enabled wiiu "${FILE}")
GAMEPAD=$(get_setting gamepad_enabled wiiu "${FILE}")

RENDERER=$(get_setting graphics_backend wiiu "${FILE}")
BACKEND=$(get_setting gdk_backend wiiu "${FILE}")
VSYNC=$(get_setting vsync wiiu "${FILE}")
GX2_DRAW_DONE_SYNC=$(get_setting gx2_draw_done_sync wiiu "${FILE}")
UPSCALE_FILTER=$(get_setting upscale_filter wiiu "${FILE}")
DOWNSCALE_FILTER=$(get_setting downscale_filter wiiu "${FILE}")
FULLSCREEN_SCALING=$(get_setting fullscreen_scaling wiiu "${FILE}")
ASYNC_SHADER_COMPILE=$(get_setting async_shader_compile wiiu "${FILE}")
VK_ACCURATE_BARRIER=$(get_setting vk_accurate_barriers wiiu "${FILE}")

OVERLAY_POSITION=$(get_setting overlay_position wiiu "${FILE}")
OVERLAY_TEXT_SCALE=$(get_setting overlay_text_scale wiiu "${FILE}")
OVERLAY_TEXT_COLOR=$(get_setting overlay_text_color wiiu "${FILE}")
OVERLAY_TEXT_TRANPARENCY=$(get_setting overlay_text_transparency wiiu "${FILE}")
OVERLAY_SHOW_FPS=$(get_setting overlay_show_fps wiiu "${FILE}")
OVERLAY_DRAW_CALLS=$(get_setting overlay_draw_calls wiiu "${FILE}")
OVERLAY_SHOW_CPU_USAGE=$(get_setting overlay_show_cpu_usage wiiu "${FILE}")
OVERLAY_SHOW_CPU_PER_CORE_USAGE=$(get_setting overlay_show_cpu_per_core_usage wiiu "${FILE}")
OVERLAY_SHOW_RAM_USAGE=$(get_setting overlay_show_ram_usage wiiu "${FILE}")
OVERLAY_SHOW_VRAM_USAGE=$(get_setting overlay_show_vram_usage wiiu "${FILE}")

NOTIFICATION_POS=$(get_setting notification_position wiiu "${FILE}")
NOTIFICATION_TEXT_SCALE=$(get_setting notification_text_scale wiiu "${FILE}")
NOTIFICATION_TEXT_COLOR=$(get_setting notification_text_color wiiu "${FILE}")
NOTIFICATION_TEXT_TRANPARENCY=$(get_setting notification_text_transparency wiiu "${FILE}")

#
# Control
#

# WiiU controller profile
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

for CONTROLLER in ${CEMU_CONFIG_ROOT}/controllerProfiles/*
do
  LOCALFILE="$(basename ${CONTROLLER})"
  if [ "${CONFILE}" = "${LOCALFILE}" ]
  then
      cp "${CONTROLLER}" "${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml"
  fi
done

UUID0="0_$(control-gen | awk 'BEGIN {FS="\""} /^DEVICE/ {print $2;exit}')"
# Check for js0, else fall back to joypad
if grep -q "js0" /proc/bus/input/devices; then
  CONTROLLER0=$(grep -b4 js0 /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')
else
  CONTROLLER0=$(grep -b4 joypad /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')
fi

xmlstarlet ed --inplace -u "//emulated_controller/type" -v "${CON}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml
xmlstarlet ed --inplace -u "//emulated_controller/controller/uuid" -v "${UUID0}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml
xmlstarlet ed --inplace -u "//emulated_controller/controller/display_name" -v "${CONTROLLER0}" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml

# WiiU controller layout
if [[ "$CON_LAYOUT" = "xbox" ]]; then
	mapping1=$(xmlstarlet sel -t -v "//entry[mapping='1']/button" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml)
	mapping2=$(xmlstarlet sel -t -v "//entry[mapping='2']/button" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml)
	mapping3=$(xmlstarlet sel -t -v "//entry[mapping='3']/button" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml)
	mapping4=$(xmlstarlet sel -t -v "//entry[mapping='4']/button" ${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml)
	xmlstarlet ed --inplace \
  -u "//entry[mapping='1']/button" -v "$mapping2" \
  -u "//entry[mapping='2']/button" -v "$mapping1" \
  -u "//entry[mapping='3']/button" -v "$mapping4" \
  -u "//entry[mapping='4']/button" -v "$mapping3" \
	${CEMU_CONFIG_ROOT}/controllerProfiles/controller0.xml
fi

#
# Online
#

# Online enable
xmlstarlet ed --inplace -u "//Account/OnlineEnabled" -v "${ONLINE}" ${CEMU_CONFIG_ROOT}/settings.xml

#
# Graphic
#

# Graphic backend
# Assume Vulkan
case ${RENDERER} in
  opengl)
    RENDERER=0
  ;;
  *)
    RENDERER=1
  ;;
esac

xmlstarlet ed --inplace -u "//Graphic/api" -v "${RENDERER}" ${CEMU_CONFIG_ROOT}/settings.xml

# GDK backend
case ${BACKEND} in
  x11)
    export GDK_BACKEND=x11
  ;;
  *)
    export GDK_BACKEND=wayland
  ;;
esac

# Vsync
[[ -z $VSYNC ]] && VSYNC="1"

# GX2 draw done sync
[[ -z $GX2_DRAW_DONE_SYNC ]] && GX2_DRAW_DONE_SYNC="true"
xmlstarlet ed --inplace -u "//Graphic/GX2DrawdoneSync" -v "$GX2_DRAW_DONE_SYNC" ${CEMU_CONFIG_ROOT}/settings.xml

# Upscale filter
[[ -z $UPSCALE_FILTER ]] && UPSCALE_FILTER="1"
xmlstarlet ed --inplace -u "//Graphic/UpscaleFilter" -v "$UPSCALE_FILTER" ${CEMU_CONFIG_ROOT}/settings.xml

# Downscale filter
[[ -z $DOWNSCALE_FILTER ]] && DOWNSCALE_FILTER="0"
xmlstarlet ed --inplace -u "//Graphic/DownscaleFilter" -v "$DOWNSCALE_FILTER" ${CEMU_CONFIG_ROOT}/settings.xml

# Fullscreen scaling
[[ -z $FULLSCREEN_SCALING ]] && FULLSCREEN_SCALING="0"
xmlstarlet ed --inplace -u "//Graphic/FullscreenScaling" -v "$FULLSCREEN_SCALING" ${CEMU_CONFIG_ROOT}/settings.xml

# Async shader compile
[[ -z $ASYNC_SHADER_COMPILE ]] && ASYNC_SHADER_COMPILE="true"
xmlstarlet ed --inplace -u "//Graphic/AsyncCompile" -v "$ASYNC_SHADER_COMPILE" ${CEMU_CONFIG_ROOT}/settings.xml

# VK accurate barrier
[[ -z $VK_ACCURATE_BARRIER ]] && VK_ACCURATE_BARRIER="true"
xmlstarlet ed --inplace -u "//Graphic/vkAccurateBarriers" -v "$VK_ACCURATE_BARRIER" ${CEMU_CONFIG_ROOT}/settings.xml

#
# Overlay
#

# Overlay position
[[ -z $OVERLAY_POSITION ]] && OVERLAY_POSITION="0"
xmlstarlet ed --inplace -u "//Overlay/Position" -v "${OVERLAY_POSITION}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay text scale
[[ -z $OVERLAY_TEXT_SCALE ]] && OVERLAY_TEXT_SCALE="100"
xmlstarlet ed --inplace -u "//Overlay/TextScale" -v "${OVERLAY_TEXT_SCALE}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay text color and transparency
[[ -z $OVERLAY_TEXT_COLOR ]] && OVERLAY_TEXT_COLOR="FFFFFF"
[[ -z $OVERLAY_TEXT_TRANPARENCY ]] && OVERLAY_TEXT_TRANPARENCY="FF"

TEXT_COLOR=`echo "ibase=16; ${OVERLAY_TEXT_TRANPARENCY}${OVERLAY_TEXT_COLOR}" | bc`
xmlstarlet ed --inplace -u "//Overlay/TextColor" -v "${TEXT_COLOR}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay show fps
[[ -z $OVERLAY_SHOW_FPS ]] && OVERLAY_SHOW_FPS="true"
xmlstarlet ed --inplace -u "//Overlay/FPS" -v "${OVERLAY_SHOW_FPS}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay draw calls
[[ -z $OVERLAY_DRAW_CALLS ]] && OVERLAY_DRAW_CALLS="false"
xmlstarlet ed --inplace -u "//Overlay/DrawCalls" -v "${OVERLAY_DRAW_CALLS}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay show cpu usage
[[ -z $OVERLAY_SHOW_CPU_USAGE ]] && OVERLAY_SHOW_CPU_USAGE="true"
xmlstarlet ed --inplace -u "//Overlay/CPUUsage" -v "${OVERLAY_SHOW_CPU_USAGE}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay show cpu per core usage
[[ -z $OVERLAY_SHOW_CPU_PER_CORE_USAGE ]] && OVERLAY_SHOW_CPU_PER_CORE_USAGE="true"
xmlstarlet ed --inplace -u "//Overlay/CPUPerCoreUsage" -v "${OVERLAY_SHOW_CPU_PER_CORE_USAGE}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay show ram usage
[[ -z $OVERLAY_SHOW_RAM_USAGE ]] && OVERLAY_SHOW_RAM_USAGE="true"
xmlstarlet ed --inplace -u "//Overlay/RAMUsage" -v "${OVERLAY_SHOW_RAM_USAGE}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay show vram usage
[[ -z $OVERLAY_SHOW_VRAM_USAGE ]] && OVERLAY_SHOW_VRAM_USAGE="true"
xmlstarlet ed --inplace -u "//Overlay/VRAMUsage" -v "${OVERLAY_SHOW_VRAM_USAGE}" ${CEMU_CONFIG_ROOT}/settings.xml

#
# Notification
#

# Notification position
[[ -z $NOTIFICATION_POSITION ]] && NOTIFICATION_POSITION="0"
xmlstarlet ed --inplace -u "//Notification/Position" -v "${NOTIFICATION_POSITION}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay text scale
[[ -z $NOTIFICATION_TEXT_SCALE ]] && NOTIFICATION_TEXT_SCALE="100"
xmlstarlet ed --inplace -u "//Notification/TextScale" -v "${NOTIFICATION_TEXT_SCALE}" ${CEMU_CONFIG_ROOT}/settings.xml

# Overlay text color and transparency
[[ -z $NOTIFICATION_TEXT_COLOR ]] && NOTIFICATION_TEXT_COLOR="FFFFFF"
[[ -z $NOTIFICATION_TEXT_TRANPARENCY ]] && NOTIFICATION_TEXT_TRANPARENCY="FF"

TEXT_COLOR=`echo "ibase=16; ${NOTIFICATION_TEXT_TRANPARENCY}${NOTIFICATION_TEXT_COLOR}" | bc`
xmlstarlet ed --inplace -u "//Notification/TextColor" -v "${TEXT_COLOR}" ${CEMU_CONFIG_ROOT}/settings.xml

#
# Misc
#

xmlstarlet ed --inplace -u "//fullscreen" -v "true" ${CEMU_CONFIG_ROOT}/settings.xml
xmlstarlet ed --inplace -u "//Audio/TVDevice" -v "${PASINK}" ${CEMU_CONFIG_ROOT}/settings.xml

#
# Dual screen gamepad
#

if [ -z "${GAMEPAD}" ]; then
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    xmlstarlet ed --inplace -u "//open_pad" -v "true" ${CEMU_CONFIG_ROOT}/settings.xml
  fi
else
  xmlstarlet ed --inplace -u "//open_pad" -v "${GAMEPAD}" ${CEMU_CONFIG_ROOT}/settings.xml
fi

# Run the emulator
cemu -g "$@"

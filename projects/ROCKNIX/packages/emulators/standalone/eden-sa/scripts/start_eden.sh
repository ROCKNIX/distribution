#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

#Check if eden exists in .config
# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/eden"
IMMUTABLE_CONF_FILE="${IMMUTABLE_CONF_DIR}/qt-config.ini"
APPIMAGE_CONF_DIR="/storage/.local/share/eden"
CONF_DIR="/storage/.config/eden"

#Init config dir if required
[ ! -d "${CONF_DIR}" ] && cp -r "${IMMUTABLE_CONF_DIR}" /storage/.config

#Init config file if required
[ ! -f "${CONF_FILE}" ] && cp ${IMMUTABLE_CONF_FILE} ${CONF_FILE}

#Link config dir to where appimage can find it
mkdir -p /storage/.local/share
rm -rf "${APPIMAGE_CONF_DIR}"
ln -sfv "${CONF_DIR}" "${APPIMAGE_CONF_DIR}"

#if [ ! -d "/storage/.config/eden" ]; then
#    mkdir -p "/storage/.config/eden"
#        cp -r "/usr/config/eden" "/storage/.config/"
#fi

#Check if qt-config.ini exists in .config/eden
if [ ! -f "${CONF_DIR}/qt-config.ini" ]; then
        cp -r "/usr/config/eden/qt-config.ini" "${CONF_DIR}/qt-config.ini"
fi

#Move Nand / Saves to switch roms folder
if [ ! -d "/storage/roms/bios/eden/nand" ]; then
    mkdir -p "/storage/roms/bios/eden/nand"
fi

rm -rf "${CONF_DIR}/nand"
ln -sfv "/storage/roms/bios/eden/nand" "${CONF_DIR}/nand"

#Link eden keys to bios folder
if [ ! -d "/storage/roms/bios/eden/keys" ]; then
    mkdir -p "/storage/roms/bios/eden/keys"
fi

rm -rf "${CONF_DIR}/keys"
ln -sfv "/storage/roms/bios/eden/keys" "${CONF_DIR}/keys"

#Link  .config/eden to .local
rm -rf "${APPIMAGE_CONF_DIR}"
ln -sfv "${CONF_DIR}" "${APPIMAGE_CONF_DIR}"

#Set QT Platform to Wayland-EGL
export QT_QPA_PLATFORM=xcb

#eden won't work with the pipewire driver yet
export SDL_AUDIODRIVER=pulseaudio

set_kill set "-9 eden"

#Run eden emulator
/usr/bin/eden -f -g "${1}"

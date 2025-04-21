#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)

. /etc/profile

clear > /dev/console

DEST="/storage/roms/bios/rtp"

SHASUMS="ddd519b50a22a2a95beeb831d29f7d7d92ae6263f953491163b446b808b66863  rpg2003_rtp_installer.zip#ec82b92da65ca6fdb2d3df25dfbcd7f2bb716e4fe63a079e8e5e396e91fa5e29  rpg2000_rtp_installer.exe"

install_bios() {
  BIOS="$1"
  BIOSPATH="$2"
  if [ -d "${INSTALLPATH}/${BIOSPATH}" ]
  then
    rm -rf "${INSTALLPATH}/${BIOSPATH}"
  fi
  mkdir -p "${INSTALLPATH}/${BIOSPATH}"
  cd "${INSTALLPATH}/${BIOSPATH}"
  curl -Lo "${BIOS}" "${PKG_URL}/${BIOS}"
  BINSUM=$(sha256sum "${BIOS}" | awk '{print $1}')
  SHASUM=$(echo $SHASUMS | tr '#' '\n' | awk '/'${BIOS}'/ {print $1}')
  if [ ! "${SHASUM}" == "${BINSUM}" ]
  then
    echo "Checksum mismatch, please update the package."
    exit 1
  fi
  if [[ "${BIOS}" =~ .zip$ ]]
  then
    /usr/bin/7z x "${BIOS}"
    rm "${BIOS}"
    BIOS="$(echo ${BIOS} | sed "s#.zip#.exe#")"
  fi
  /usr/bin/7z x "${BIOS}"
  rm "${BIOS}"
  cd ${SOURCEPATH}
}

INSTALLPATH="/storage/roms/bios"
SOURCEPATH="$(pwd)"
PKG_NAME="rpgmaker"
PKG_VERSION="1.0.0"
PKG_URL="https://dl.degica.com/rpgmakerweb/run-time-packages"

# Check if the easyrpg runtime files are already available
[ "$(ls -A ${DEST})" ] && JDKINSTALLED="yes" || JDKINSTALLED="no"

if [ ${JDKINSTALLED} == "no" ]; then
  mkdir -p ${DEST}
  echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
  if [ $? -ne 0 ]; then
      text_viewer -e -w -t "No Internet!" -m "You need to be connected to the internet to download the easyrpg runtime files.";
      exit 1
  fi
  echo "Downloading easyrpg runtime files please be patient..." > /dev/console

  install_bios rpg2000_rtp_installer.exe rtp/2000
  install_bios rpg2003_rtp_installer.zip rtp/2003

  echo "Done! loading core!" > /dev/console
fi

clear > /dev/console < /dev/null 2>&1
exit 0

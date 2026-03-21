# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="drastic-sa"
PKG_VERSION="1.0"
PKG_LICENSE="Proprietary:DRASTIC.pdf"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey"
PKG_LONGDESC="Install Drastic Launcher script, will download bin on first run"
PKG_TOOLCHAIN="make"

make_target() {
  ${CC} ${CFLAGS} -shared -fPIC -o libdrastouch.so \
    ${PKG_DIR}/sources/libdrastouch.c -ldl
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_drastic.sh
  
  mkdir -p ${INSTALL}/usr/lib
  cp -f ${PKG_BUILD}/libdrastouch.so ${INSTALL}/usr/lib/

  mkdir -p ${INSTALL}/usr/config/drastic/config
  cp -rf ${PKG_BUILD}/drastic_aarch64/* ${INSTALL}/usr/config/drastic/
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/drastic/config/
  cp -rf ${PKG_DIR}/config/drastic.gptk ${INSTALL}/usr/config/drastic/

  mkdir -p ${INSTALL}/usr/config/drastic/microphone
  cp -f ${PKG_DIR}/sources/microphone.wav ${INSTALL}/usr/config/drastic/microphone/
}

post_install() {
    case ${DEVICE} in
      RK3588)
        HOTKEY="export HOTKEY="guide""
      ;;
      *)
        HOTKEY=""
      ;;
    esac
    sed -e "s/@HOTKEY@/${HOTKEY}/g" \
        -i ${INSTALL}/usr/bin/start_drastic.sh
}

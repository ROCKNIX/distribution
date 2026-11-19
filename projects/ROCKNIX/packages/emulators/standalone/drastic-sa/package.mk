# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="drastic-sa"
PKG_VERSION="1.0"
PKG_SHA256="b7bbeb7493bcc355619880c0929cf2709e264f0785ab709a9c305e73b1199b30"
PKG_LICENSE="proprietary"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey"
PKG_LONGDESC="Install Drastic Launcher script, will download bin on first run"
PKG_TOOLCHAIN="make"

make_target() {
  ${CC} ${CFLAGS} -shared -fPIC -o libdrastouch.so ${PKG_BUILD}/libdrastouch.c -ldl
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_drastic.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
    cp -a ${PKG_BUILD}/libdrastouch.so ${INSTALL}/usr/lib

  mkdir -p ${INSTALL}/usr/config/drastic/config
    cp -a ${PKG_BUILD}/drastic_aarch64/* ${INSTALL}/usr/config/drastic
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/drastic/config
    cp -a ${PKG_DIR}/config/drastic.gptk ${INSTALL}/usr/config/drastic

  mkdir -p ${INSTALL}/usr/config/drastic/microphone
    cp -a ${PKG_DIR}/sources/microphone.wav ${INSTALL}/usr/config/drastic/microphone/
}

post_install() {
  case ${DEVICE} in
    RK3588) HOTKEY="export HOTKEY="guide"" ;;
    *) HOTKEY="" ;;
  esac

  sed -e "s/@HOTKEY@/${HOTKEY}/g" -i ${INSTALL}/usr/bin/start_drastic.sh
}

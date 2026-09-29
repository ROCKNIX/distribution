# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="drastic-sa"
PKG_VERSION="1.0"
PKG_SHA256="b7bbeb7493bcc355619880c0929cf2709e264f0785ab709a9c305e73b1199b30"
PKG_LICENSE="proprietary"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey"
PKG_LONGDESC="Install Drastic Launcher script, will download bin on first run"
# aarch64 only, restored after the 2026-09 upstream cleanup dropped it
# (28e750db32): the download is an arm64 binary with no x86_64 build to
# fetch. virtual/emulators adds this package only in aarch64 device arms
# (the base PKG_EMUS names amiberry and yabasanshiro-sa for every device,
# not this one), so PKG_ARCH is belt and braces here -- it keeps the recipe
# off x86_64 should a device arm or `make world` ever list it there (the
# earlier comment claimed the base list did; audit #258 PL-010).
PKG_ARCH="aarch64"
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

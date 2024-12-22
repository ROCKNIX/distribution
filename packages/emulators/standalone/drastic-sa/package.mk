# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="drastic-sa"
PKG_VERSION="1.0"
PKG_LICENSE="Proprietary:DRASTIC.pdf"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey"
PKG_LONGDESC="Install Drastic Launcher script, will dowload bin on first run"
PKG_TOOLCHAIN="make"

if [ "${DEVICE}" = "S922X" ]; then
  PKG_DEPENDS_TARGET+=" libegl"
fi

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_drastic.sh
  chmod +x ${INSTALL}/usr/bin/drastic_sense.sh

  mkdir -p ${INSTALL}/usr/config/drastic/config
  cp -rf ${PKG_BUILD}/drastic_aarch64/* ${INSTALL}/usr/config/drastic/
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/drastic/config/
  cp -rf ${PKG_DIR}/config/drastic.gptk ${INSTALL}/usr/config/drastic/
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

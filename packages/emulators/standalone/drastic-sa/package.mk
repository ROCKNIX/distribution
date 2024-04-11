# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="drastic-sa"
PKG_VERSION="1.0"
PKG_LICENSE="Proprietary:DRASTIC.pdf"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/r3claimer/JelosAddOns/raw/main/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain rocknix-hotkey"
PKG_LONGDESC="Install Drastic Launcher script, will dowload bin on first run"
PKG_TOOLCHAIN="make"

if [ "${DEVICE}" = "S922X" -a "${USE_MALI}" != "no" ]; then
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
      S922X)
        if [ "${USE_MALI}" != "no" ]; then
          LIBEGL="export SDL_VIDEO_GL_DRIVER=\/usr\/lib\/egl\/libGL.so.1 SDL_VIDEO_EGL_DRIVER=\/usr\/lib\/egl\/libEGL.so.1"
        else
          LIBEGL=""
        fi
        
        HOTKEY=""
      ;;
      RK3588)
        LIBEGL=""
        HOTKEY="export HOTKEY="guide""
      ;;
      *)
        LIBEGL=""
        HOTKEY=""
      ;;
    esac
    sed -e "s/@LIBEGL@/${LIBEGL}/g" \
        -i ${INSTALL}/usr/bin/start_drastic.sh
    sed -e "s/@HOTKEY@/${HOTKEY}/g" \
        -i ${INSTALL}/usr/bin/start_drastic.sh
}

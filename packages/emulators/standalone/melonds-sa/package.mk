# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="melonds-sa"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/melonDS-emu/melonDS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="SDL2 qt5 libslirp libepoxy libarchive ecm libpcap control-gen"
PKG_LONGDESC="DS emulator, sorta. The goal is to do things right and fast"
PKG_TOOLCHAIN="cmake"

case ${DEVICE} in
  AMD64)
    PKG_VERSION="f454eba3c3243b095f0e6b9ddde3e68b095c5d8d"
    PKG_URL="${PKG_SITE}.git"
  ;;
  *)
    PKG_VERSION="ca7fb4f55e8fdad53993ba279b073f97f453c13c"
    PKG_URL="${PKG_SITE}.git"
  ;;
esac

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_INSTALL_PREFIX="/usr" \
                         -DBUILD_SHARED_LIBS=OFF"


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/melonDS ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/melonDS
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/melonDS
  cp -rf ${PKG_DIR}/config/melonDS.gptk ${INSTALL}/usr/config/melonDS

  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_melonds.sh
}

post_install() {
  case ${TARGET_ARCH} in
    aarch64)
      PANFROST="export MESA_GL_VERSION_OVERRIDE=3.3"
      ;;
    *)
      PANFROST=""
    ;;
  esac
  sed -e "s/@PANFROST@/${PANFROST}/g" \
        -i ${INSTALL}/usr/bin/start_melonds.sh
  case ${DEVICE} in
    RK3588)
      HOTKEY="export HOTKEY="guide""
      ;;
    *)
      HOTKEY=""
    ;;
  esac
  sed -e "s/@HOTKEY@/${HOTKEY}/g" \
        -i ${INSTALL}/usr/bin/start_melonds.sh
}

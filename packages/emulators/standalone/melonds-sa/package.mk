# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-2024 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-sa"
PKG_VERSION="a72b79a55ad2d61811af11b1b911f6af863f66c2"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/melonDS-emu/melonDS"
PKG_URL="https://github.com/melonDS-emu/melonDS/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="SDL2 qt6 libslirp libepoxy libarchive ecm libpcap control-gen"
PKG_LONGDESC="DS emulator, sorta. The goal is to do things right and fast"
PKG_TOOLCHAIN="cmake"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_INSTALL_PREFIX="/usr" \
                         -DUSE_QT6=ON \
                         -DBUILD_SHARED_LIBS=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -P ${PKG_BUILD}/.${TARGET_NAME}/melonDS ${INSTALL}/usr/bin
  cp -P ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/melonDS
  cp ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/melonDS
  cp ${PKG_DIR}/config/melonDS.gptk ${INSTALL}/usr/config/melonDS
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
      LIBMALI="if [ ! -z 'lsmod | grep panfrost' ]; then sed -i '\/ScreenUseGL=\/c\\\ScreenUseGL=0' \/storage\/.config\/melonDS\/melonDS.ini; fi"
      ;;
    RK3566*)
      HOTKEY=""
      LIBMALI="if [ ! -z 'lsmod | grep panfrost' ]; then sed -i '\/ScreenUseGL=\/c\\\ScreenUseGL=0' \/storage\/.config\/melonDS\/melonDS.ini; fi"
      ;;
    *)
      HOTKEY=""
      LIBMALI=""
      ;;
  esac

  sed -e "s/@HOTKEY@/${HOTKEY}/g" \
      -i ${INSTALL}/usr/bin/start_melonds.sh

  sed -e "s/@LIBMALI@/${LIBMALI}/g" \
      -i ${INSTALL}/usr/bin/start_melonds.sh
}

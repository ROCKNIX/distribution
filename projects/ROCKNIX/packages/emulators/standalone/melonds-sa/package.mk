# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="melonds-sa"
PKG_VERSION="b7bfb539e57366d85c31999cb57cfa35d681d4a9"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/melonDS-emu/melonDS"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="SDL2 qt6 libslirp libepoxy libarchive ecm libpcap control-gen faad2"
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

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

pre_configure_target() {
export CFLAGS+=" -Wno-sign-compare"
export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_INSTALL_PREFIX="/usr" \
                         -DUSE_QT6=ON \
                         -DBUILD_SHARED_LIBS=OFF"
}


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

  # Platform hotkeys
  case ${DEVICE} in
    RK3588|S922X|SM8*)
      HOTKEY="export HOTKEY="guide""
    ;;
    *)
      HOTKEY=""
    ;;
  esac

  # Libmali check - force software renderer
  case ${DEVICE} in
    RK3588|S922X|RK3566)
      LIBMALI="if [[ -x \"\/usr\/bin\/gpudriver\" ]] \&\& [[ \"\$\(\/usr\/bin\/gpudriver\)\" = \"libmali\" ]]; then sed -i '\/ScreenUseGL=\/c\\\ScreenUseGL=0' \/storage\/.config\/melonDS\/melonDS.ini; fi"
    ;;
    *)
      LIBMALI=""
    ;;
  esac

  sed -e "s/@HOTKEY@/${HOTKEY}/g" \
        -i ${INSTALL}/usr/bin/start_melonds.sh
  sed -e "s/@LIBMALI@/${LIBMALI}/g" \
        -i ${INSTALL}/usr/bin/start_melonds.sh
}

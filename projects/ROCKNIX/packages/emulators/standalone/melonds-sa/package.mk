# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="melonds-sa"
PKG_VERSION="906e9ebb27da8c6a715cd7abab4abfe8a8d29427"
PKG_SHA256="5edcd49fe593df24e47f29eb27636c8c4d3698dc21ac224697708a8fcd9ea262"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/melonDS-emu/melonDS"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="SDL2 qt6 libslirp libepoxy libarchive ecm libpcap control-gen faad2"
PKG_LONGDESC="DS emulator, sorta. The goal is to do things right and fast"

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
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

get_graphicdrivers

if listcontains "${GRAPHIC_DRIVERS}" "(panfrost)"; then
  GRAPHICS_DRIVER="panfrost"
fi

PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                         -DCMAKE_INSTALL_PREFIX="/usr" \
                         -DUSE_QT6=ON \
                         -DENABLE_RETROACHIEVEMENTS=ON \
                         -DBUILD_SHARED_LIBS=OFF"

pre_configure_target() {
  export CFLAGS+=" -Wno-sign-compare"
  export CXXFLAGS="${CXXFLAGS} -Wno-sign-compare"

  mkdir -p ${PKG_BUILD}/src/frontend/qt_sdl/retroachievements/resources/sounds
    touch ${PKG_BUILD}/src/frontend/qt_sdl/retroachievements/resources/sounds/unlock.wav

  mkdir -p ${PKG_BUILD}/src/frontend/qt_sdl/retroachievements/resources/icons
    cp -a ${PKG_DIR}/resources/ra-icon.png ${PKG_BUILD}/src/frontend/qt_sdl/retroachievements/resources/icons/ra-icon.png
    touch ${PKG_BUILD}/src/frontend/qt_sdl/retroachievements/resources/icons/placeholder.png
}


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/melonDS ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/melonDS
    cp -a ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/melonDS
    cp -a ${PKG_DIR}/config/melonDS.gptk ${INSTALL}/usr/config/melonDS
}

post_install() {
  PANFROST=""
  [ "${GRAPHICS_DRIVER}" = "panfrost" ] && PANFROST="export MESA_GL_VERSION_OVERRIDE=3.3"

  HOTKEY=""
  case "${DEVICE}" in
    RK3588|S922X|SM*) hotkey='export HOTKEY="guide"' ;;
  esac

  LIBMALI=""
  case "${DEVICE}" in
    RK3588|S922X|RK3566)
      LIBMALI='if [[ -x "/usr/bin/gpudriver" ]] && [[ "$(/usr/bin/gpudriver)" = "libmali" ]]; then sed -i '\''/ScreenUseGL=/c\\ScreenUseGL=0'\'' /storage/.config/melonDS/melonDS.ini; fi'
      ;;
  esac

  sed -e "s|@PANFROST@|${PANFROST}|g" \
      -e "s|@HOTKEY@|${HOTKEY}|g" \
      -e "s|@LIBMALI@|${LIBMALI}|g" \
      -i ${INSTALL}/usr/bin/start_melonds.sh
}

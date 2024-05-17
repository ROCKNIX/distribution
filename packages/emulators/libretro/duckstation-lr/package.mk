# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="duckstation-lr"
PKG_VERSION="24c373245ebdab946f11627520edea76e1f23b8e"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 nasm:host pulseaudio openssl libidn2 nghttp2 zlib curl libevdev"
PKG_LONGDESC="DuckStation - PlayStation 1, aka. PSX Emulator"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {
  case ${TARGET_ARCH} in
    x86_64)
      CFLAGS+=" -march=x86-64"
    ;;
  esac

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_SDL_FRONTEND=OFF \
                         -DBUILD_QT_FRONTEND=OFF \
                         -DBUILD_LIBRETRO_CORE=ON \
			 -DENABLE_DISCORD_PRESENCE=OFF \
			 -DUSE_X11=OFF"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/duckstation_libretro.so ${INSTALL}/usr/lib/libretro/
}

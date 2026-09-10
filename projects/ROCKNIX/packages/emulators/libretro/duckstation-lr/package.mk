# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="duckstation-lr"
PKG_VERSION="24c373245ebdab946f11627520edea76e1f23b8e"
PKG_SHA256="a716d0caa55c24cfa23495d46bf5268a58fec0055e23df41caa7239d7da28fa4"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 nasm:host pulseaudio openssl libidn2 nghttp2 zlib curl libevdev"
PKG_LONGDESC="DuckStation - PlayStation 1, aka. PSX Emulator"

PKG_CMAKE_OPTS_TARGET+=" -DBUILD_SDL_FRONTEND=OFF \
                         -DBUILD_QT_FRONTEND=OFF \
                         -DBUILD_LIBRETRO_CORE=ON \
                         -DENABLE_DISCORD_PRESENCE=OFF \
                         -DUSE_X11=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/duckstation_libretro.so ${INSTALL}/usr/lib/libretro
}

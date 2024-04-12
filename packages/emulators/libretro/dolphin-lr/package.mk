# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dolphin-lr"
PKG_VERSION="2f4b0f7902257d40a054f60b2c670d6e314f2a04"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain libevdev libdrm ffmpeg zlib libpng lzo libusb"
PKG_SITE="https://github.com/libretro/dolphin"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Dolphin Libretro, a Gamecube & Wii emulator core for Retroarch"
PKG_TOOLCHAIN="cmake"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CONFIGURE_OPTS_TARGET+=" -DENABLE_X11=OFF \
                               -DENABLE_EGL=ON"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CONFIGURE_OPTS_TARGET+=" -DENABLE_X11=OFF \
                               -DENABLE_EGL=ON"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi"
  PKG_CONFIGURE_OPTS_TARGET+=" -DENABLE_X11=ON \
                               -DENABLE_EGL=ON"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_CONFIGURE_OPTS_TARGET+=" -DENABLE_VULKAN=ON"
fi

pre_configure_target() {
        PKG_CMAKE_OPTS_TARGET+="        -DENABLE_EGL=ON \
                                        -DUSE_SHARED_ENET=OFF \
                                        -DUSE_UPNP=ON \
                                        -DENABLE_NOGUI=ON \
                                        -DENABLE_QT=OFF \
                                        -DENABLE_LTO=ON \
                                        -DENABLE_GENERIC=OFF \
                                        -DENABLE_HEADLESS=ON \
                                        -DENABLE_ALSA=ALSA \
                                        -DENABLE_PULSEAUDIO=ON \
                                        -DENABLE_LLVM=OFF \
                                        -DENABLE_TESTS=OFF \
                                        -DUSE_DISCORD_PRESENCE=OFF \
                                        -DLIBRETRO=ON"
                                        }

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/dolphin_libretro.so ${INSTALL}/usr/lib/libretro/
}

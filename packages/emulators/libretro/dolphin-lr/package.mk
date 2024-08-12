# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="dolphin-lr"
PKG_VERSION="89a4df725d4eb24537728f7d655cddb1add25c18"
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

pre_configure_target() 

  if [ "${ARCH}" = "aarch64" ]; then
    # This is only needed for armv8.2-a targets where we don't use this flag
    # as it prohibits the use of LSE-instructions, this is a package bug most likely
    export CFLAGS="${CFLAGS} -mno-outline-atomics"
    export CXXFLAGS="${CXXFLAGS} -mno-outline-atomics"
  fi
{
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

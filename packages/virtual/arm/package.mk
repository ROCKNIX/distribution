# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="arm"
PKG_LICENSE="GPLv2"
PKG_SITE="https://rocknix.org"
PKG_DEPENDS_TARGET="toolchain libc gcc libusb  SDL2 SDL2_gfx SDL2_image SDL2_mixer SDL2_net SDL2_ttf"
PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to build and create 32-bit userland"

### Display Drivers
if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd glew"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland libXtst libXfixes libXi gdk-pixbuf libvdpau"
  case ${ARCH} in
    arm|i686)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
fi

### Audio
if [ "${PIPEWIRE_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" pipewire"
fi

### Emulators and Cores
if [ "${EMULATION_DEVICE}" = "yes" ]; then
  EMUS_32BIT=$(ENABLE_32BIT=true bash -c ". ${ROOT}/packages/virtual/emulators/package.mk; echo \$EMUS_32BIT")
  PKG_DEPENDS_TARGET+=" retroarch ${EMUS_32BIT}"
fi

PKG_DEPENDS_TARGET+=" ${ADDITIONAL_PACKAGES_32BIT}"

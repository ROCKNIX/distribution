# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aethersx2-sa"
PKG_VERSION="1.5-3606"
PKG_SHA256="b44fe609f2914627c2f9d9dba2513e8f6b72d5679e47b2dadabcd28aa05b8b43"
PKG_LICENSE="proprietary"
PKG_SITE="https://github.com/ROCKNIX/packages"
PKG_URL="${PKG_SITE}/raw/refs/heads/main/aethersx2.tar.gz"
PKG_DEPENDS_TARGET="toolchain qt6 libgpg-error fuse2 xz libpcap"
PKG_LONGDESC="Arm PS2 Emulator appimage"
# aarch64 only, restored after the 2026-09 upstream cleanup dropped it
# (28e750db32): the download is an arm64 binary with no x86_64 build to
# fetch. virtual/emulators adds this package only in aarch64 device arms
# (the base PKG_EMUS names amiberry and yabasanshiro-sa for every device,
# not this one), so PKG_ARCH is belt and braces here -- it keeps the recipe
# off x86_64 should a device arm or `make world` ever list it there (the
# earlier comment claimed the base list did; audit #258 PL-010).
PKG_ARCH="aarch64"
PKG_TOOLCHAIN="manual"

get_graphicdrivers

if listcontains "${GRAPHIC_DRIVERS}" "(panfrost)"; then
  GRAPHICS_DRIVER="panfrost"
elif listcontains "${GRAPHIC_DRIVERS}" "(freedreno)"; then
  GRAPHICS_DRIVER="freedreno"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/aethersx2-sa
    cp -a ${PKG_BUILD}/usr/share/* ${INSTALL}/usr/share/aethersx2-sa
    cp -a ${PKG_DIR}/sources/* ${INSTALL}/usr/share/aethersx2-sa

  mkdir -p ${INSTALL}/usr/config
    cp -a ${PKG_DIR}/config/${DEVICE}/aethersx2 ${INSTALL}/usr/config
}

post_install() {
  case ${GRAPHICS_DRIVER} in
    panfrost) GRAPHICS="export MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330" ;;
    freedreno)
      case ${DEVICE} in
        SM8250) GRAPHICS="export TU_DEBUG=sysmem" ;;
        *) GRAPHICS="" ;;
      esac
      ;;
    *) GRAPHICS="" ;;
  esac

  sed -e "s/@GRAPHICS@/${GRAPHICS}/g" -i ${INSTALL}/usr/bin/start_aethersx2.sh
}

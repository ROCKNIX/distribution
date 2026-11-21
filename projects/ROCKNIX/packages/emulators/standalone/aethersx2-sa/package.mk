# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aethersx2-sa"
PKG_DEPENDS_TARGET="toolchain qt6 libgpg-error fuse2 xz libpcap"
PKG_LONGDESC="Bring your own Arm PS2 Emulator"
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

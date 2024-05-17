# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="idtech-lr"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://rocknix.org"
PKG_LONGDESC="Package for all iD Software game engines."
PKG_TOOLCHAIN="manual"
PKG_DOOM_SHAREWARE="https://github.com/ROCKNIX/packages/raw/main/doom.tar.gz"

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_DEPENDS_TARGET+=" ecwolf-lr prboom-lr tyrquake-lr vitaquake2-lr"
fi

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" vitaquake3-lr boom3-lr"
fi

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/idtech
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/share/idtech
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/share/idtech/
  curl -Lo ${INSTALL}/usr/share/idtech/doom.tar.gz ${PKG_DOOM_SHAREWARE}
}

post_install() {
  case ${TARGET_ARCH} in
    aarch64)
      sed -i '/doom3/d' ${INSTALL}/usr/share/idtech/idtech_dirs
      sed -i '/quake3/d' ${INSTALL}/usr/share/idtech/idtech_dirs
    ;;
  esac
}

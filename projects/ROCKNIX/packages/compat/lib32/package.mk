# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)

PKG_NAME="lib32"
PKG_VERSION="1.0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain retroarch SDL2 libsndfile libmodplug"
PKG_LONGDESC="ARM 32bit bundle for aarch64"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-strip"

makeinstall_target() {
  case ${TARGET_ARCH} in
    aarch64)
      LIBARCH="arm"
      LDSO="ld-linux-armhf.so.3"
      ;;
  esac

  cd ${PKG_BUILD}
  LIBROOT="${ROOT}/build.${DISTRO}-${DEVICE}.${LIBARCH}/image/system/"
  mkdir -p ${INSTALL}/usr/lib32
  rsync -al ${LIBROOT}/usr/lib/* ${INSTALL}/usr/lib32 >/dev/null 2>&1
  rsync -al ${LIBROOT}/usr/lib32/* ${INSTALL}/usr/lib32 >/dev/null 2>&1
  mkdir -p ${INSTALL}/usr/lib
  ln -s /usr/lib32/${LDSO} ${INSTALL}/usr/lib/${LDSO}

  mkdir -p "${INSTALL}/etc/ld.so.conf.d"
  echo "/usr/lib32" > "${INSTALL}/etc/ld.so.conf.d/${LIBARCH}-lib32.conf"

  mkdir -p ${INSTALL}/usr/bin
  cp ${LIBROOT}/usr/bin/ldd ${INSTALL}/usr/bin/ldd32
}

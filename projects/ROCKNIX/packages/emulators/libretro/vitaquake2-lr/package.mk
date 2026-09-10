# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vitaquake2-lr"
PKG_VERSION="59a511555106eef7156c1f34d1ee6c47d11cc4ee"
PKG_SHA256="7d70a312da16e93ec5a764c95fa1ffe42f484432b9b0ca8f83550874ed1c8725"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/libretro/vitaquake2"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain vitaquake2-rogue-lr vitaquake2-xatrix-lr vitaquake2-zaero-lr"
PKG_LONGDESC="Libretro port of VitaQuakeII (Quake 2 engine)"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

pre_make_target() {
  export BUILD_SYSROOT=${SYSROOT_PREFIX}

  case ${TARGET_ARCH} in
    aarch64) PKG_MAKE_OPTS_TARGET+=" platform=${DEVICE}_rocknix" ;;
  esac
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
    cp -a vitaquake2_libretro.so $INSTALL/usr/lib/libretro
}

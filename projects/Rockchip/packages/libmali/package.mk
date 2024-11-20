# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali"
PKG_VERSION="g13p0"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/tsukumijima/libmali-rockchip"
# zip format makes extract very fast (<1s). tgz takes 20 seconds to scan the whole file
#PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.zip"
PKG_URL="${PKG_SITE}/archive/master.zip"
PKG_DEPENDS_TARGET="toolchain libdrm patchelf:host gpudriver"
PKG_LONGDESC="OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_TOOLCHAIN="meson"
PKG_PATCH_DIRS+=" ${DEVICE}"

# patchelf is incompatible with strip, but is needed to ensure apps call wrapped functions
PKG_BUILD_FLAGS="-strip"

case "${DISPLAYSERVER}" in
  wl)
    PLATFORM="wayland-gbm"
    PKG_DEPENDS_TARGET+=" wayland"
    ;;
  x11)
    PLATFORM="x11-gbm"
    ;;
  *)
    PLATFORM="gbm"
    ;;
esac

PKG_MESON_OPTS_TARGET+=" -Darch=${ARCH} -Dgpu=${MALI_FAMILY} -Dversion=${PKG_VERSION} -Dplatform=${PLATFORM} \
                       -Dkhr-header=false -Dvendor-package=true -Dwrappers=enabled -Dhooks=true"


unpack() {
  mkdir -p "${PKG_BUILD}"
  cd "${PKG_BUILD}"
  pwd
  # Extract only what is needed
  LIBNAME="libmali-${MALI_FAMILY}-${PKG_VERSION}-${PLATFORM}.so"
  unzip -q "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}" "*/hook/*" "*/include/*" "*/scripts/*" "*/meson*" "*/${LIBNAME}"
  mv libmali-rockchip-*/* .
  rmdir libmali-rockchip-*
  ln -s lib optimize_3
}

post_makeinstall_target() {
  rm -rf "${SYSROOT_PREFIX}/usr/include"   # all needed headers are installed by glvnd, mesa and wayland
  rm -rf "${INSTALL}/etc/ld.so.conf.d" "${SYSROOT_PREFIX}/etc/ld.so.conf.d"  # upstream installs ld.so config and we don't need it

  # IDK how libs in ubuntu package get these dependencies. Need to specify them manually here.
  for lib in "${INSTALL}"/usr/lib*/mali/lib*.so.*; do
    patchelf --add-needed libmali-hook.so.1 "${lib}"
  done
  patchelf --add-needed libmali.so.1 "${INSTALL}"/usr/lib*/libmali-hook.so.1

  # x11 lib needed for some applications on the RK3588
  if [ ${DEVICE} = "RK3588" ] && [ ${TARGET_ARCH} = "aarch64" ]; then
      curl -Lo ${INSTALL}/usr/lib/libmali-${MALI_FAMILY}-${PKG_VERSION}-x11-gbm.so ${PKG_SITE}/raw/master/lib/aarch64-linux-gnu/libmali-${MALI_FAMILY}-${PKG_VERSION}-x11-gbm.so
  fi
}

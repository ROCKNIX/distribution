# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali"
PKG_VERSION="v1.9-1-b9619b9"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/tsukumijima/libmali-rockchip"
# zip format makes extract very fast (<1s). tgz takes 20 seconds to scan the whole file
PKG_URL="https://github.com/tsukumijima/libmali-rockchip/archive/refs/tags/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain libdrm patchelf:host"
PKG_LONGDESC="OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_TOOLCHAIN="meson"

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

PKG_MESON_OPTS_TARGET+=" -Darch=${ARCH} -Dgpu=${MALI_FAMILY} -Dversion=${MALI_VERSION} -Dplatform=${PLATFORM} \
                       -Dkhr-header=false -Dvendor-package=true -Dwrappers=enabled -Dhooks=true"


unpack() {
  mkdir -p "${PKG_BUILD}"
  cd "${PKG_BUILD}"
  pwd
  # Extract only what is needed
  LIBNAME="libmali-${MALI_FAMILY}-${MALI_VERSION}-${PLATFORM}.so"
  unzip -q "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}" "*/hook/*" "*/include/*" "*/scripts/*" "*/meson*" "*/${LIBNAME}"
  mv libmali-rockchip-*/* .
  rmdir libmali-rockchip-*
  ln -s lib optimize_3
}

pre_make_target() {
  patchelf --rename-dynamic-symbols "${PKG_BUILD}/rename.syms" libmali-prebuilt.so
}

post_makeinstall_target() {
  rm -rf "${SYSROOT_PREFIX}/usr/include"   # all needed headers are installed by glvnd, mesa and wayland
  rm -rf "${INSTALL}/etc/ld.so.conf.d" "${SYSROOT_PREFIX}/etc/ld.so.conf.d"
  mkdir "${INSTALL}/etc/ld.so.conf.d"
  echo "include /storage/.cache/ld.so.libmali.conf" > "${INSTALL}/etc/ld.so.conf.d/__priority__libmali.conf"

  for lib in "${INSTALL}/usr/lib*/mali/*.so"; do
    echo ${lib}
    patchelf --add-needed libmali-hook.so.1 ${lib}
  done

  mkdir -p "${INSTALL}/usr/bin/"
  cp -v "${PKG_BUILD}/bin/gpudriver" "${INSTALL}/usr/bin/"
}

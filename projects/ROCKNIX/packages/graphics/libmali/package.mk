# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libmali"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/ROCKNIX/libmali"
PKG_VERSION="0fe30426b822699f0a660268a6040fdafce229d1"
# zip format makes extract very fast (<1s). tgz takes 20 seconds to scan the whole file
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain libdrm patchelf:host gpudriver SDL2_glesonly"
PKG_LONGDESC="OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_TOOLCHAIN="meson"
PKG_PATCH_DIRS+=" ${DEVICE}"

# patchelf is incompatible with strip, but is needed to ensure apps call wrapped functions
PKG_BUILD_FLAGS="-strip"

case "${DEVICE}" in
  S922X)
    DRIVER_VERSION="r51p0"
    PKG_DEPENDS_TARGET+=" vulkan-wsi-layer vulkan-tools"
  ;;
  RK3588)
    DRIVER_VERSION="g13p0"
  ;;
  *) # RK3326 and RK3566
    DRIVER_VERSION="g24p0"
  ;;
esac

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

PKG_MESON_OPTS_TARGET+=" -Darch=${ARCH} -Dgpu=${MALI_FAMILY} -Dversion=${DRIVER_VERSION} -Dplatform=${PLATFORM} \
                       -Dkhr-header=false -Dvendor-package=true -Dwrappers=enabled -Dhooks=true"


unpack() {
  mkdir -p "${PKG_BUILD}"
  cd "${PKG_BUILD}"
  pwd
  # Extract only what is needed
  LIBNAME="libmali-${MALI_FAMILY}-${DRIVER_VERSION}-${PLATFORM}.so"
  unzip -q "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}" "*/hook/*" "*/include/*" "*/scripts/*" "*/meson*" "*/data/*" "*/${LIBNAME}"
  mv libmali*/* .
  rmdir libmali-*
  if [ "${MALI_FAMILY}" = "meson" ]; then
    mv data/vulkan/mali_meson.json.in data/vulkan/mali.json.in
  fi
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
      curl -Lo ${INSTALL}/usr/lib/libmali-${MALI_FAMILY}-${DRIVER_VERSION}-x11-gbm.so ${PKG_SITE}/raw/master/lib/aarch64-linux-gnu/libmali-${MALI_FAMILY}-${DRIVER_VERSION}-x11-gbm.so
  fi
  # S922X - mali vulkan libs need moving
  if [ "${DEVICE}" = "S922X" ] && [ "${ARCH}" = "aarch64" ]; then
    mv "${INSTALL}"/usr/lib/mali/libMaliVulkan.* "${INSTALL}"/usr/lib/
  fi
}

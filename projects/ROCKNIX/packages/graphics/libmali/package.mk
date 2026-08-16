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
esac

case "${DISPLAYSERVER}" in
  wl)
    PLATFORM="-wayland-gbm"
    PKG_DEPENDS_TARGET+=" wayland"
    ;;
  x11)
    PLATFORM="-x11-gbm"
    ;;
  *)
    PLATFORM="-gbm"
    ;;
esac

# new repo base from jeffycn mirror
case "${DEVICE}" in
  RK3326|RK3566|RK3576)
    PKG_SITE="https://github.com/JeffyCN/mirrors"
    PKG_VERSION="4233031d818e97a19e8a9cdbbd5c15795ededd93"
    # zip format makes extract very fast (<1s). tgz takes 20 seconds to scan the whole file
    PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.zip"
    PKG_DEPENDS_TARGET+=" mesa vulkan-tools vulkan-headers vulkan-wsi-layer"
    DRIVER_VERSION="g29p1"
    PLATFORM=""
    ZIPDIRNAME="mirrors"
    PKG_PATCH_DIRS+=" next"
    OPTS=" -Dwrappers=true "
    MALI_G29="yes"
  ;;
  *)
    OPTS=" -Dwrappers=enabled "
    ZIPDIRNAME="libmali"
  ;;
esac


PKG_MESON_OPTS_TARGET+=" -Darch=${ARCH} -Dgpu=${MALI_FAMILY} -Dversion=${DRIVER_VERSION} -Dplatform=${PLATFORM} \
                       -Dkhr-header=false -Dvendor-package=true -Dhooks=true ${OPTS}"


unpack() {
  mkdir -p "${PKG_BUILD}"
  cd "${PKG_BUILD}"
  pwd
  # Extract only what is needed
  LIBNAME="libmali-${MALI_FAMILY}-${DRIVER_VERSION}${PLATFORM}.so"
  unzip -q "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}" "*/hook/*" "*/include/*" "*/scripts/*" "*/meson*" "*/data/*" "*/${LIBNAME}"
  mv ${ZIPDIRNAME}*/* .
  rmdir ${ZIPDIRNAME}-*
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
  if [[ "${DEVICE}" =~ S922X|RK3326|RK3566|RK3576 ]] && [ "${ARCH}" = "aarch64" ]; then
    mv "${INSTALL}"/usr/lib/mali/libMaliVulkan.* "${INSTALL}"/usr/lib/
  fi
  if [[ "${DEVICE}" =~ RK3326|RK3566|RK3576 ]] && [ "${ARCH}" = "arm" ]; then
    mv "${INSTALL}"/usr/lib32/mali/libMaliVulkan.* "${INSTALL}"/usr/lib32/
  fi

  # Provide RUNPATH for 32bit mali blobs 
  if [ "${ARCH}" = "arm" ]; then
    for lib in "${INSTALL}"/usr/lib32/lib*.so.* \
               "${INSTALL}"/usr/lib32/mali/lib*.so.*; do
      [ -f "${lib}" ] && [ ! -L "${lib}" ] || continue
      patchelf --set-rpath '/usr/lib32' "${lib}"
    done
  fi

  # Patch libmali to enable 32bit Vulkan
  if [ -n "${MALI_G29}" ] && [ "${ARCH}" = "arm" ]; then
    for so in "${INSTALL}"/usr/lib32/libmali.so.*.*; do
      [ -f "${so}" ] && [ ! -L "${so}" ] || continue
      python3 "${PKG_DIR}/scripts/note_fullgap.py" "${so}"
    done
  fi
}

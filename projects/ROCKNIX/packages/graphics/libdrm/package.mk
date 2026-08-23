# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libdrm"
PKG_VERSION="2.4.134"
PKG_SHA256="ac5e74d157830eb8bee44c6a6bf3ad49774ef0dd2a72bdad74a8f20308b52a95"
PKG_LICENSE="MIT"
PKG_SITE="https://dri.freedesktop.org"
PKG_URL="https://dri.freedesktop.org/libdrm/libdrm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain libpciaccess"
PKG_LONGDESC="The userspace interface library to kernel DRM services."

get_graphicdrivers

PKG_MESON_OPTS_COMMON="-Dnouveau=disabled \
                       -Domap=disabled \
                       -Dexynos=disabled \
                       -Dtegra=disabled \
                       -Dcairo-tests=disabled \
                       -Dman-pages=disabled \
                       -Dvalgrind=disabled \
                       -Dfreedreno-kgsl=false \
                       -Dudev=false"

PKG_MESON_OPTS_HOST="${PKG_MESON_OPTS_COMMON} \
                     -Damdgpu=disabled \
                     -Detnaviv=disabled \
                     -Dfreedreno=disabled \
                     -Dintel=disabled \
                     -Dradeon=disabled \
                     -Dvc4=disabled \
                     -Dvmwgfx=disabled \
                     -Dtests=false \
                     -Dinstall-test-programs=false"

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_COMMON} \
                     -Dtests=true \
                     -Dinstall-test-programs=true"

listcontains "${GRAPHIC_DRIVERS}" "(crocus|i915|iris)" &&
  PKG_MESON_OPTS_TARGET+=" -Dintel=enabled" || PKG_MESON_OPTS_TARGET+=" -Dintel=disabled"

listcontains "${GRAPHIC_DRIVERS}" "(r300|r600|radeonsi)" &&
  PKG_MESON_OPTS_TARGET+=" -Dradeon=enabled" || PKG_MESON_OPTS_TARGET+=" -Dradeon=disabled"

listcontains "${GRAPHIC_DRIVERS}" "radeonsi" &&
  PKG_MESON_OPTS_TARGET+=" -Damdgpu=enabled" || PKG_MESON_OPTS_TARGET+=" -Damdgpu=disabled"

listcontains "${GRAPHIC_DRIVERS}" "vmware" &&
  PKG_MESON_OPTS_TARGET+=" -Dvmwgfx=enabled" || PKG_MESON_OPTS_TARGET+=" -Dvmwgfx=disabled"

listcontains "${GRAPHIC_DRIVERS}" "vc4" &&
  PKG_MESON_OPTS_TARGET+=" -Dvc4=enabled" || PKG_MESON_OPTS_TARGET+=" -Dvc4=disabled"

listcontains "${GRAPHIC_DRIVERS}" "freedreno" &&
  PKG_MESON_OPTS_TARGET+=" -Dfreedreno=enabled" || PKG_MESON_OPTS_TARGET+=" -Dfreedreno=disabled"

listcontains "${GRAPHIC_DRIVERS}" "etnaviv" &&
  PKG_MESON_OPTS_TARGET+=" -Detnaviv=enabled" || PKG_MESON_OPTS_TARGET+=" -Detnaviv=disabled"

post_makeinstall_target() {
  # Remove all test programs installed by install-test-programs=true except modetest
  PKG_LIBDRM_LIST="drmdevice modeprint proptest vbltest"
  for PKG_LIBDRM_TEST in ${PKG_LIBDRM_LIST}; do
    safe_remove ${INSTALL}/usr/bin/${PKG_LIBDRM_TEST}
  done

  if listcontains "${GRAPHIC_DRIVERS}" "radeonsi"; then
    safe_remove ${INSTALL}/usr/bin/amdgpu_stress
  fi

  # modetest is kept, we use it for display bring-up
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/tests/modetest/modetest ${INSTALL}/usr/bin/

  # the installed headers include <drm.h>, which only resolves for consumers
  # that add /usr/include/drm to their search path
  for header in xf86drm.h xf86drmMode.h; do
    sed -i "s#<drm.h>#<drm/drm.h>#g" ${SYSROOT_PREFIX}/usr/include/${header}
    sed -i "s#<drm_mode.h#<drm/drm_mode.h>#g" ${SYSROOT_PREFIX}/usr/include/${header}
  done
}

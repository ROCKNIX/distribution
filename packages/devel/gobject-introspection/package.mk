# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gobject-introspection"
PKG_VERSION="1.78.1"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.gtk.org/"
PKG_URL="https://github.com/GNOME/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libffi glib Python3 qemu:host gobject-introspection:host"
PKG_DEPENDS_HOST="libffi:host glib:host"
PKG_LONGDESC="glib: C support library"
PKG_TOOLCHAIN="meson"

pre_configure_host() {
  PKG_MESON_OPTS_HOST=" \
    -Ddoctool=disabled"

  # prevent g-ir-scanner from writing cache data to $HOME
  export GI_SCANNER_DISABLE_CACHE="1"

  CC="${HOST_CC}"
  CXX="${HOST_CXX}"
  AR="${HOST_AR}"
  CPP="${HOST_PREFIX}cpp"
  CPPFLAGS="${HOST_CPPFLAGS}"
  CFLAGS="${HOST_CFLAGS} -fPIC"
  LDFLAGS="${HOST_LDFLAGS}"
}

pre_configure_target() {
  GLIBC_DYNAMIC_LINKER="$(ls ${SYSROOT_PREFIX}/usr/lib/ld-linux-*.so.*)"
  QEMU_BINARY="${TOOLCHAIN}/bin/qemu-${TARGET_ARCH}"
  PKG_CONFIG_PATH="${SYSROOT_PREFIX}/usr/lib/pkgconfig"

  TARGET_LDFLAGS="${TARGET_LDFLAGS} -Wl,--dynamic-linker=${GLIBC_DYNAMIC_LINKER}"

  # for gi this variables must be defined for target and not for host
  # because they are used in
  # toolchain/lib/gobject-introspection/giscanner/ccompiler.py
  CC="${TARGET_CC}"
  CXX="${TARGET_CXX}"
  AR="${TARGET_AR}"
  CPP="${TARGET_PREFIX}cpp"
  CPPFLAGS="${TARGET_CPPFLAGS}"
  CFLAGS="${TARGET_CFLAGS} -fPIC"
  LDFLAGS="${TARGET_LDFLAGS}"

  PKG_MESON_OPTS_TARGET=" \
    -Ddoctool=disabled \
    -Dpython=${TOOLCHAIN}/bin/${PKG_PYTHON_VERSION} \
    -Dgi_cross_use_prebuilt_gi=true \
    -Dgi_cross_binary_wrapper=${TOOLCHAIN}/bin/g-ir-scanner-binary-wrapper \
    -Dgi_cross_ldd_wrapper=${TOOLCHAIN}/bin/g-ir-scanner-ldd-wrapper \
    -Dbuild_introspection_data=true"

  # prevent g-ir-scanner from writing cache data to $HOME
  export GI_SCANNER_DISABLE_CACHE="1"

  # write out a qemu wrapper that will be given to gi-scanner
  # so that it can run target helper binaries through that
  cat > ${TOOLCHAIN}/bin/g-ir-scanner-binary-wrapper << EOF
#!/bin/sh
  ${QEMU_BINARY} \
    -E LD_LIBRARY_PATH="${SYSROOT_PREFIX}/usr/lib:${TOOLCHAIN}/${TARGET_NAME}/lib" \
    -L ${SYSROOT_PREFIX}/usr \
    "\$@"
EOF

  # write out a wrapper to use instead of ldd, which does not
  # work when a binary is built for a different architecture
  cat > ${TOOLCHAIN}/bin/g-ir-scanner-ldd-wrapper << EOF
#!/bin/sh
  ${QEMU_BINARY} \
    -E LD_LIBRARY_PATH="${SYSROOT_PREFIX}/usr/lib:${TOOLCHAIN}/${TARGET_NAME}/lib" \
    ${GLIBC_DYNAMIC_LINKER} --list "\$1"
EOF

  chmod +x ${TOOLCHAIN}/bin/g-ir-scanner-*-wrapper
}


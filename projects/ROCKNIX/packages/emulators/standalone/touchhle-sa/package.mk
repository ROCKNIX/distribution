# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="touchhle-sa"
PKG_LICENSE="MPLv2"
PKG_VERSION="3c5850585ba55615b17a58c58331b6d6f52d4a9d"
PKG_SITE="https://github.com/touchHLE/touchHLE"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust SDL2 openal-soft sndio libsamplerate"
PKG_LONGDESC="touchHLE: high-level emulator for iPhone OS apps"
PKG_TOOLCHAIN="manual"

make_target() {
  unset CMAKE
  export RUSTFLAGS="-C link-arg=-lasound"
  export CMAKE_POLICY_VERSION_MINIMUM="3.5"
  export CFLAGS="${CFLAGS} -std=gnu11"

  # rustc 1.95 destabilised custom target JSON specs (rust-lang/rust#150151):
  # loading one now needs -Zunstable-options, and -Z needs a nightly or
  # bootstrapped compiler. Our TARGET_NAME is a custom triple, so this is
  # unavoidable - the kernel does the same for its own custom targets.
  export RUSTC_BOOTSTRAP=1
  export RUSTFLAGS="${RUSTFLAGS} -Zunstable-options"

  # touchHLE defaults to the "static" feature, which bundles its own SDL2 and
  # openal-soft. The vendored SDL2 predates pipewire 1.6 and no longer builds,
  # and we already ship both libraries, so link the system ones instead.
  cargo build \
    --no-default-features \
    --target ${TARGET_NAME} \
    --release
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/touchHLE ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs
  cp -rf ${PKG_BUILD}/touchHLE_dylibs/lib* ${INSTALL}/usr/lib/touchHLE/touchHLE_dylibs/
  mkdir -p ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_fonts/LiberationSans-* ${INSTALL}/usr/lib/touchHLE/touchHLE_fonts
  cp -rf ${PKG_BUILD}/touchHLE_default_options.txt ${INSTALL}/usr/lib/touchHLE/
  mkdir -p ${INSTALL}/usr/config/touchHLE
  cp -rf ${PKG_BUILD}/touchHLE_options.txt ${INSTALL}/usr/config/touchHLE/
  chmod +x ${INSTALL}/usr/bin/*
}

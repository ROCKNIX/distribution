# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="cargo-c"
PKG_VERSION="0.10.22"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/lu-zero/cargo-c"
PKG_URL="${PKG_SITE}/archive/v${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cargo:host rust:host"
PKG_DEPENDS_UNPACK="cargo-c-lock"
PKG_LONGDESC="A cargo subcommand to build and install C-ABI compatible dynamic and static libraries"
PKG_TOOLCHAIN="manual"

pre_configure_host() {
  cp ${SOURCES}/cargo-c-lock/cargo-c-lock-${PKG_VERSION}.Cargo.lock Cargo.lock
}

configure_host() {
  cargo fetch --locked --target ${RUST_HOST}
}

make_host() {
  cargo build --features=vendored-openssl --release --frozen
}

makeinstall_host() {
  find ".${RUST_HOST}/target/release" -maxdepth 1 -type f -executable -exec install -D -m755 -t "${TOOLCHAIN}/bin" {} +
}

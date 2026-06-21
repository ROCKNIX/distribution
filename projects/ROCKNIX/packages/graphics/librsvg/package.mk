# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017 Escalade
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="librsvg"
PKG_VERSION="aa54b088216d7cc42ad9b0978df45fd72db6786d"
PKG_LICENSE="LGPL"
PKG_SITE="https://gitlab.gnome.org/GNOME/librsvg"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo-c:host rust:host gdk-pixbuf cairo freetype harfbuzz pango libxml2 glib"
PKG_LONGDESC="SVG rendering library"

PKG_MESON_OPTS_TARGET="-Davif=disabled \
                       -Dtests=false \
                       -Dintrospection=disabled \
                       -Dpixbuf=enabled \
                       -Drsvg-convert=disabled \
                       -Dpixbuf-loader=enabled \
                       -Ddocs=disabled \
                       -Dvala=disabled \
                       -Dtriplet=${TARGET_NAME}"

export RUST_TARGET_PATH=${TOOLCHAIN}/lib/rustlib

pre_configure_target() {
  pushd ${PKG_BUILD}

  mkdir .cargo
  cat >.cargo/config.toml <<END
[target.${TARGET_NAME}]
linker = "${TARGET_PREFIX}gcc"
END
  cargo fetch --locked --target host-tuple

  popd
}

post_makeinstall_target() {
  mv ${INSTALL}/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader{_,-}svg.so
}

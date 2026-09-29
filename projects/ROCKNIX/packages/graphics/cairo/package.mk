# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cairo"
# Why this override exists beside packages/graphics/cairo: the generic recipe
# builds cairo for x11 alone (libXrender/libX11 under DISPLAYSERVER=x11, xcb
# disabled); ROCKNIX's Wayland devices need the xcb and xlib-xcb surfaces,
# and the meson options below turn those on. (cairo 1.18 has no GL or GLES
# backend: the OPENGL/OPENGLES dependencies in configure_package order the
# build and select nothing.) The version is the release the generic
# recipe would have too -- 1.18.4 is what pango 1.58 requires (1e5b87963a;
# upstream PR 3359 carries the same bump) -- so once that PR merges the
# version line here is redundant and only the options keep the override.
PKG_VERSION="1.18.4"
PKG_SHA256="445ed8208a6e4823de1226a74ca319d3600e83f6369f99b14265006599c32ccb"
PKG_LICENSE="LGPL-2.1-or-later OR MPL-1.1"
PKG_SITE="https://cairographics.org/"
PKG_URL="https://cairographics.org/releases/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib freetype fontconfig glib libpng pixman"
PKG_LONGDESC="Cairo is a vector graphics library with cross-device output support."

configure_package() {
  if [ "${OPENGL}" != "no" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL}"
  fi

  if [ "${OPENGLES}" != "no" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi

  case ${DISPLAYSERVER} in
    "x11"|"wl")
      PKG_DEPENDS_TARGET+=" libxcb libXrender libX11 mesa"
    ;;
  esac

}

pre_configure_target() {
  PKG_MESON_OPTS_TARGET="-Ddwrite=disabled \
                         -Dfontconfig=enabled \
                         -Dfreetype=enabled \
                         -Dpng=enabled \
                         -Dquartz=disabled \
                         -Dtee=disabled \
                         -Dtests=disabled \
                         -Dzlib=enabled \
                         -Dgtk2-utils=disabled \
                         -Dglib=enabled \
                         -Dspectre=disabled \
                         -Dsymbol-lookup=disabled \
                         -Dgtk_doc=false"

  case ${DISPLAYSERVER} in
    "x11"|"wl")
      PKG_MESON_OPTS_TARGET+=" -Dxlib=enabled \
                               -Dxcb=enabled \
                               -Dxlib-xcb=enabled"
    ;;
    *)
      PKG_MESON_OPTS_TARGET+=" -Dxlib=disabled \
                               -Dxcb=disabled \
                               -Dxlib-xcb=disabled"
    ;;
  esac
  # ipc_rmid_deferred_release comes from the meson cross file
  # (create_meson_conf_target in config/functions sets it to true).
}

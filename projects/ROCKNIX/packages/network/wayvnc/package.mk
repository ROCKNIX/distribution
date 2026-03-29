# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="wayvnc"
PKG_VERSION="477ef59b1ea19f96d6a57ac3572f1fb33c117672"
PKG_SHA256="3ff0f3f7994712612f898b3896eb9ea3bf64a65cf39311876b072393931c3d20"
PKG_LICENSE="ISC"
PKG_SITE="https://github.com/any1/wayvnc"
PKG_URL="https://github.com/any1/wayvnc/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain sway libdrm pixman libxkbcommon wayland wayland-protocols jansson gnutls libjpeg-turbo nettle gmp ffmpeg"
PKG_LONGDESC="wayvnc: VNC server for wlroots-based Wayland compositors"
PKG_TOOLCHAIN="meson"

# neatvnc and aml are built as meson subprojects (tightly version-coupled)
_NEATVNC_VERSION="28d902a73f11d76d9fc6ad6117fd1e35961fad0a"
_AML_VERSION="ce4b82d5888a87110054b95414bd3068224d2b91"

PKG_MESON_OPTS_TARGET="-Dpam=disabled \
                       -Dman-pages=disabled \
                       -Dtests=false \
                       -Dscreencopy-dmabuf=auto \
                       -Dneatvnc:jpeg=enabled \
                       -Dneatvnc:tls=enabled \
                       -Dneatvnc:h264=enabled \
                       -Dneatvnc:nettle=enabled \
                       -Dneatvnc:gbm=auto \
                       -Dneatvnc:tests=false \
                       -Dneatvnc:examples=false \
                       -Dneatvnc:benchmarks=false"

pre_configure_target() {
  # Download neatvnc and aml as meson subprojects
  mkdir -p ${PKG_BUILD}/subprojects

  # neatvnc
  if [ ! -d "${PKG_BUILD}/subprojects/neatvnc" ]; then
    wget -q -O ${PKG_BUILD}/subprojects/neatvnc.tar.gz \
      "https://github.com/any1/neatvnc/archive/${_NEATVNC_VERSION}.tar.gz"
    tar xf ${PKG_BUILD}/subprojects/neatvnc.tar.gz -C ${PKG_BUILD}/subprojects
    mv ${PKG_BUILD}/subprojects/neatvnc-${_NEATVNC_VERSION} \
       ${PKG_BUILD}/subprojects/neatvnc
    rm ${PKG_BUILD}/subprojects/neatvnc.tar.gz
  fi

  # aml
  if [ ! -d "${PKG_BUILD}/subprojects/aml" ]; then
    wget -q -O ${PKG_BUILD}/subprojects/aml.tar.gz \
      "https://github.com/any1/aml/archive/${_AML_VERSION}.tar.gz"
    tar xf ${PKG_BUILD}/subprojects/aml.tar.gz -C ${PKG_BUILD}/subprojects
    mv ${PKG_BUILD}/subprojects/aml-${_AML_VERSION} \
       ${PKG_BUILD}/subprojects/aml
    rm ${PKG_BUILD}/subprojects/aml.tar.gz
  fi
}

post_makeinstall_target() {
  # Remove man pages, headers, pkgconfig — only need the binaries + neatvnc .so
  rm -rf ${INSTALL}/usr/share/man
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/lib/pkgconfig
}

post_install() {
  enable_service wayvnc.service
}

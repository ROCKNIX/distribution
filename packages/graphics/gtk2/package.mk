# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017 Escalade
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gtk2"
PKG_VERSION="2.24.33"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.gtk.org/"
PKG_URL="https://ftp.gnome.org/pub/gnome/sources/gtk+/${PKG_VERSION:0:4}/gtk+-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain at-spi2-atk atk cairo gdk-pixbuf glib libX11 libXi libXrandr libepoxy pango libxkbcommon wayland wayland-protocols libepoxy libpng tiff libjpeg-turbo libffi glew"
PKG_DEPENDS_CONFIG="libXft pango gdk-pixbuf shared-mime-info"
PKG_LONGDESC="A library for creating graphical user interfaces for the X Window System."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--with-x \
						  --enable-introspection=no \
						  --disable-cups \
						  --disable-glibtest \
						  --enable-xinerama=no \
						  --disable-maintainer-mode "

pre_configure_target() {
  # ${TOOLCHAIN}/bin/glib-compile-resources requires ${TOOLCHAIN}/lib/libffi.so.6
  export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:${LD_LIBRARY_PATH}"
  export GLIB_COMPILE_RESOURCES=glib-compile-resources GLIB_MKENUMS=glib-mkenums GLIB_GENMARSHAL=glib-genmarshal
}


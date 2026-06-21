# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017 Escalade
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="adwaita-icon-theme"
PKG_VERSION="551245ae75fdc42cde42a8cf24ca2ccab9d3a815"
PKG_LICENSE="LGPL"
PKG_SITE="https://gitlab.gnome.org/GNOME/adwaita-icon-theme"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="GNOME standard icons"

makeinstall_target() {
	meson install --destdir DESTDIR
	rm -r DESTDIR/usr/share/icons/Adwaita/cursors
	mkdir -p ${INSTALL}/usr/share/icons
	cp -LRf {DESTDIR,${INSTALL}}/usr/share/icons/Adwaita
}

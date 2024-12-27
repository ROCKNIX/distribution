# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-2024 Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="retrorun"
PKG_VERSION="95ac0bf3a921beefee8b3bbf2faf89eef18f9b3a"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/navy1978/retrorun"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain librga libdrm"
PKG_TOOLCHAIN="make"

pre_configure_target() {
	PKG_MAKE_OPTS_TARGET=" config=release ARCH="
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin
	cp retrorun $INSTALL/usr/bin
}

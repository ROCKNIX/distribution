# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lxqt-build-tools"
PKG_VERSION="2.2.0"
PKG_SHA256="ecee3248c9435580e9eec844d8b2a989bbf1472cc292a04bc4f8708127fea1c5"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/lxqt/lxqt-build-tools"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Several tools needed to build LXQt itself as well as other components maintained by the LXQt project."
PKG_DEPENDS_TARGET="toolchain qt6"
PKG_TOOLCHAIN="cmake"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr
}

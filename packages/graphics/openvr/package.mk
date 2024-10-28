# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="openvr"
PKG_VERSION="ebd425331229365dc3ec42d1bb8b2cc3c2332f81"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ValveSoftware/openvr"
PKG_URL="https://github.com/ValveSoftware/openvr.git"
PKG_DEPENDS_TARGET="toolchain jsoncpp"
PKG_LONGDESC="API and runtime that allows access to VR hardware from multiple vendors"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"
pre_configure_target() {
  :
}

post_makeinstall_target() {
:
}

post_install() {
:
}


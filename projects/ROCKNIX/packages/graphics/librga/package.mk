# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="librga"
PKG_VERSION="57a1067a246c71fa6c9a355d1668884fda155dd5"
PKG_ARCH="arm aarch64"
PKG_LICENSE="Apache-2.0"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_SITE="https://github.com/JeffyCN/mirrors"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="linux-rga-multi"
PKG_GIT_CLONE_SINGLE="yes"
PKG_LONGDESC="RGA is an independent 2D hardware acceleration userspace driver"
PKG_TOOLCHAIN="meson"

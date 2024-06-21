# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Nicholas Ricciuti (https://github.com/rishooty)

PKG_NAME="python3-packaging"
PKG_VERSION="24.1"
PKG_SHA256="026ed72c8ed3fcce5bf8950572258698927fd1dbda10a5e981cdf0ac37f4f002"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://pypi.org/project/packaging/"
PKG_URL="https://files.pythonhosted.org/packages/source/p/packaging/packaging-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Core utilities for Python packages."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/python3.11/site-packages
  cp -r ${PKG_BUILD}/src/packaging ${SYSROOT_PREFIX}/usr/lib/python3.11/site-packages
}

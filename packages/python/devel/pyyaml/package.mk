# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2024-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pyyaml"
PKG_VERSION="6.0.2"
PKG_LICENSE="MIT"
PKG_SITE="https://pypi.org/project/PyYAML/"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="Python3:host setuptools:host"
PKG_LONGDESC="YAML parser and emitter for Python"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  export DONT_BUILD_LEGACY_PYC=1
  exec_thread_safe python3 setup.py install --prefix="${TOOLCHAIN}"
}

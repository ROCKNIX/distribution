# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pyelftools"
PKG_VERSION="0.30"
PKG_LICENSE="Unlicense"
PKG_SITE="https://github.com/eliben/pyelftools"
PKG_URL="https://github.com/eliben/pyelftools/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain Python3:host"
PKG_LONGDESC="Library for analyzing ELF files and DWARF debugging information"
PKG_TOOLCHAIN="manual"

make_host() {
  ${TOOLCHAIN}/bin/python3 setup.py build
}

makeinstall_host() {
  exec_thread_safe ${TOOLCHAIN}/bin/python3 setup.py install --prefix=${TOOLCHAIN} --skip-build

  # Avoid using full path to python3 that may exceed 128 byte limit.
  # Instead use PATH as we know our toolchain is first.
  sed -e '1 s/^#!.*$/#!\/usr\/bin\/env python3/' -i ${TOOLCHAIN}/bin/meson
}

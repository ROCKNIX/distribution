# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="pyudev"
PKG_VERSION="5e00141"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/pyudev/pyudev"
PKG_URL="https://github.com/pyudev/pyudev/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 setuptools:host"
PKG_LONGDESC="pyudev is a LGPL licenced, pure Python 2/3 binding to libudev, the device and hardware management and information library of Linux."
PKG_TOOLCHAIN="python"

post_makeinstall_target() {
  python_remove_source
}

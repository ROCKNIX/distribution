# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libmali-vulkan"
PKG_VERSION="r51p0-00eac0"
PKG_LICENSE="mali_driver"
PKG_ARCH="arm aarch64"
PKG_SITE="https://developer.arm.com/downloads/-/mali-drivers/user-space"
PKG_URL="https://developer.arm.com/-/media/Files/downloads/mali-drivers/user-space/odroid-n2plus/BXODROIDN2PL-${PKG_VERSION}.tar"
PKG_DEPENDS_TARGET="toolchain mesa vulkan-tools"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Vulkan Mali drivers for s922x soc"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/{lib,share}
  tar -xvJf ${PKG_BUILD}/mali.tar.xz -C ${INSTALL}
  mv ${INSTALL}/lib/${TARGET_ARCH}-linux-gnu/* ${INSTALL}/usr/lib
  rm -r ${INSTALL}/lib
  tar -xvJf ${PKG_BUILD}/rootfs_additions.tar.xz -C ${INSTALL}/usr/share
  mv ${INSTALL}/usr/share/etc/vulkan/* ${INSTALL}/usr/share/vulkan/
  rm -r ${INSTALL}/usr/share/etc
}

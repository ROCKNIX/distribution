# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="g610-mali-csffw"
PKG_VERSION="e08ced3e0235b25a7ba2a3aeefd0e2fcbd434b68"
PKG_SHA256="bc5d30e325d45cd7fb76deb57e3e0f1fa027f40a7b71318067798700f3e9a384"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/JeffyCN/mirrors"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Mali blob needed for RK3588 gpu"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

#Panfork needs v
makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
    cp -a ${PKG_BUILD}/firmware/g610/mali_csffw.bin ${INSTALL}/$(get_full_firmware_dir)
}

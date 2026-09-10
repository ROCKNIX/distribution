# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot-DDR4"
PKG_VERSION="v2026.01"
PKG_SHA256="03bb43c58d2343ee48dd191e0f181f0108425b179d84519add3a977071c3f654"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/u-boot/u-boot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="anbernic_rg35xx_h700_lpddr4_defconfig"
  PKG_BL31="$(get_build_dir atf)/build/sun50i_h616/release/bl31.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make BL31="${PKG_BL31}" HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
}

makeinstall_target() {
  : # nothing
}

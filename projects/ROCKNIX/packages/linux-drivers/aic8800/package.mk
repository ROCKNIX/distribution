# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800"
PKG_VERSION="5562c254b0231be34588dc608ec28c4f1d613285"
PKG_SHA256="a5d1dc573c07b23fa50fba653ae51da11e2d74e2ecfdd6d0a1cf6afa9a06be74"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="aic8800: AICSemi AIC8800 SDIO Wi-Fi driver and firmware"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

post_unpack() {
  # Apply the SDIO parts of the kernel compatibility patches shipped with the source
  for PATCH in $(cat ${PKG_BUILD}/debian/patches/series); do
    awk '/^diff --git /{keep=0} /^--- /{keep=($2 ~ /^[^\/]+\/src\/SDIO\//)} keep' \
      ${PKG_BUILD}/debian/patches/${PATCH} >${PKG_BUILD}/sdio.patch
    if [ -s ${PKG_BUILD}/sdio.patch ]; then
      patch -d ${PKG_BUILD} -p1 <${PKG_BUILD}/sdio.patch
    fi
  done
}

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800
}

makeinstall_target() {
  DRIVER_DIR=${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800

  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${DRIVER_DIR}/aic8800_bsp/aic8800_bsp.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    cp ${DRIVER_DIR}/aic8800_fdrv/aic8800_fdrv.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aic8800_fw/SDIO
    cp -r ${PKG_BUILD}/src/SDIO/driver_fw/fw/aic8800D80 ${INSTALL}/$(get_full_firmware_dir)/aic8800_fw/SDIO

  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/aic8800-mac ${INSTALL}/usr/bin
}

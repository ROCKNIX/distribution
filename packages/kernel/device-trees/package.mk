# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="device-trees"
PKG_LICENSE="GPL"
PKG_LONGDESC="device-trees: ROCKNIX linux device trees"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

post_unpack() {
	# remove auto unpacked
	rm -rf ${PKG_BUILD}/${DEVICE}
	# copy only this device' device trees
	cp -r ${PKG_DIR}/sources/${DEVICE}/* ${PKG_BUILD}/
}

make_target() {
  DEVICE_TREES=($(find ${PKG_BUILD} -maxdepth 1 -name "*.dts"))
  if [ ${#DEVICE_TREES[@]} -gt 0 ]; then
  	for dts in ${PKG_BUILD}/*.dts; do
    	$(kernel_path)/scripts/dtc/dtc -@ -I dts -O dtb -o ${dts%.dts}.dtb ${dts}
  	done
  fi
  OVERLAYS=($(find ${PKG_BUILD}/overlays -maxdepth 1 -name "*.dts"))
  if [ ${#OVERLAYS[@]} -gt 0 ]; then
    for dts in ${PKG_BUILD}/overlays/*.dts; do
      $(kernel_path)/scripts/dtc/dtc -@ -I dts -O dtb -o ${dts%.dts}.dtb ${dts}
    done
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/
  DEVICE_TREE_BINARIES=($(find ${PKG_BUILD} -maxdepth 1 -name "*.dtb"))
  if [ ${#DEVICE_TREE_BINARIES[@]} -gt 0 ]; then
    cp ${PKG_BUILD}/*.dtb ${INSTALL}/usr/share/bootloader/
  fi
  if [ -d ${PKG_BUILD}/overlays ]; then
    mkdir -p ${INSTALL}/usr/share/bootloader/overlays
    cp ${PKG_BUILD}/overlays/*.dtb ${INSTALL}/usr/share/bootloader/overlays
    mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/dtb_overlay ${INSTALL}/usr/bin
  fi
}

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="inputplumber"
PKG_VERSION="0.79.0"
PKG_SHA256="9f72f52b350be3dcf71e2c4704418101dd0af9350e413a7574b30216215cec5f"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ShadowBlip/InputPlumber"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cargo:host cargo rust llvm:host systemd libevdev libiio polkit"
PKG_LONGDESC="Open source input router and remapper daemon for Linux"
PKG_TOOLCHAIN="manual"

# Upstream composite device configs for the handhelds we support ourselves.
# Our own configs (projects/ROCKNIX/devices/*/filesystem/usr/share/inputplumber)
# match the same hardware but map it to a DualSense target, so the upstream
# files would compete for the same source devices. Drop them.
PKG_DROP_DEVICE_CONFIGS="
  50-ayaneo_pocket_s2.yaml
  50-ayn_odin2.yaml
  50-ayn_odin2_mini.yaml
  50-ayn_odin3.yaml
  50-ayn_thor.yaml
  50-konkr_pocket_fit.yaml
  50-konkr_pocket_fit_elite.yaml
  50-retroid_pocket5.yaml
  50-retroid_pocket6.yaml
  50-retroid_pocket_flip2.yaml
  50-retroid_pocket_mini.yaml
  50-retroid_pocket_nova.yaml
"

post_unpack() {
  for config in ${PKG_DROP_DEVICE_CONFIGS}; do
    rm -f ${PKG_BUILD}/usr/share/inputplumber/devices/${config}
  done
}

make_target() {
  export LIBCLANG_PATH=${TOOLCHAIN}/lib
  export LD_LIBRARY_PATH=${TOOLCHAIN}/lib:${LD_LIBRARY_PATH}
  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${SYSROOT_PREFIX} -isystem ${SYSROOT_PREFIX}/usr/include"

  cargo build \
    --target ${TARGET_NAME} \
    --release
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/inputplumber ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr
  rsync -ar ${PKG_BUILD}/rootfs/usr/ ${INSTALL}/usr/

  # sources/ is overlaid with cp, so pin the mode udev needs to run the shim.
  chmod 0755 ${INSTALL}/usr/lib/inputplumber/setfacl-shim/setfacl
}

post_install() {
  enable_service inputplumber.service
}

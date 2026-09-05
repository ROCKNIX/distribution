# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="inputplumber"
PKG_VERSION="v0.79.0"
PKG_SHA256="123c858139d3b78e3f075158ce16b8fdc8067a10e31a93cb1e7f2aea816106bd"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/ShadowBlip/InputPlumber"
PKG_URL="https://github.com/ShadowBlip/InputPlumber/releases/download/${PKG_VERSION}/inputplumber-aarch64.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd libevdev libiio polkit"
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

makeinstall_target() {
  mkdir -p ${INSTALL}/usr
  rsync -ar ${PKG_BUILD}/usr/ ${INSTALL}/usr/
}

post_install() {
  enable_service inputplumber.service
}

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="steamdeck-dsp"
PKG_VERSION="0.69"
PKG_SHA256="cf1a20d93cfcf3a05d69e1389892e02f73380a02a85d6f4dee64dc98ba7efe8a"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://gitlab.com/evlaV/valve-hardware-audio-processing"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}/valve-hardware-audio-processing-${PKG_VERSION}.tar.gz"
PKG_ARCH="x86_64"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Valve's SOF firmware, topology and UCM for the Steam Deck OLED audio DSP."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/amd/{sof,sof-tplg}
    cp -a sof_fw/sof/sof-vangogh-{code,data}.bin ${INSTALL}/$(get_full_firmware_dir)/amd/sof
    cp -a sof_fw/sof-tplg/sof-vangogh-nau8821-max.tplg ${INSTALL}/$(get_full_firmware_dir)/amd/sof-tplg

  mkdir -p ${INSTALL}/usr/share/alsa/ucm2/conf.d
    cp -a ucm2/conf.d/sof-nau8821-max ${INSTALL}/usr/share/alsa/ucm2/conf.d
}

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="gpudriver"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain mesa vulkan-tools"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="GPU driver util for switching between panfrost / panthor and libmali / libmali-vulkan"

post_makeinstall_target() {
  mkdir -p "${INSTALL}/usr/bin/"
  cp -v "${PKG_BUILD}/bin/gpudriver" "${INSTALL}/usr/bin/"
  
  # set the correct mesa pan kernel driver module based on device
  case ${DEVICE} in
    RK3588)
      PAN="panthor"
      DTB_OVERLAY_LOAD="\/usr\/bin\/dtb_overlay set driver-gpu driver-gpu-panthor.dtbo"
      DTB_OVERLAY_UNLOAD="\/usr\/bin\/dtb_overlay set driver-gpu None"
    ;;
    S922X)
      PAN="panfrost"
      DTB_OVERLAY_LOAD="\/usr\/bin\/dtb_overlay set driver-gpu driver-gpu-panfrost.dtbo"
      DTB_OVERLAY_UNLOAD="\/usr\/bin\/dtb_overlay set driver-gpu None"
    ;;
    *)
      PAN="panfrost"
      DTB_OVERLAY=""
      DTB_OVERLAY_UNLOAD=""
    ;;
  esac
  
  sed -e "s/@PAN@/${PAN}/g" \
      -i  ${INSTALL}/usr/bin/gpudriver

  sed -e "s/@DTB_OVERLAY_LOAD@/${DTB_OVERLAY_LOAD}/g" \
      -i  ${INSTALL}/usr/bin/gpudriver

  sed -e "s/@DTB_OVERLAY_UNLOAD@/${DTB_OVERLAY_UNLOAD}/g" \
      -i  ${INSTALL}/usr/bin/gpudriver
}
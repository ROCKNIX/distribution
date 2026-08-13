# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/pipewire/package.mk

PKG_PATCH_DIRS+=" ${DEVICE}"

if [ "${BLUETOOTH_SUPPORT}" = "yes" ]; then
  PKG_PIPEWIRE_BLUETOOTH+=" -Dbluez5-codec-lc3plus=disabled"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_PIPEWIRE_VULKAN+="-Dvulkan=enabled \
                        -Dx11=disabled \
                        -Dx11-xfixes=disabled"
fi

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dvulkan=disabled/${PKG_PIPEWIRE_VULKAN}}"
PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dlibpulse=disabled/-Dlibpulse=enabled}"

post_makeinstall_target() {
  :
}

post_install() {
  add_user pipewire x 982 980 "pipewire-daemon" "/var/run/pipewire" "/bin/sh"
  add_group pipewire 980

  mkdir -p ${INSTALL}/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf ${INSTALL}/etc/alsa/conf.d/50-pipewire.conf
    ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf ${INSTALL}/etc/alsa/conf.d/99-pipewire-default.conf

  enable_service pipewire.socket
  enable_service pipewire.service
  enable_service pipewire-pulse.socket
  enable_service pipewire-pulse.service
}

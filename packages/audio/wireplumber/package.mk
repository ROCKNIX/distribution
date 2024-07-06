# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wireplumber"
PKG_VERSION="0.5.5"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/pipewire/wireplumber"
PKG_URL="https://gitlab.freedesktop.org/pipewire/wireplumber/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="pipewire glib lua54 glib:host"
PKG_LONGDESC="Session / policy manager implementation for PipeWire"

PKG_MESON_OPTS_TARGET="-Dintrospection=disabled \
                       -Ddoc=disabled \
                       -Dsystem-lua=true \
                       -Delogind=disabled \
                       -Dsystemd=enabled \
                       -Dsystemd-system-service=true \
                       -Dsystemd-user-service=false \
                       -Dsystemd-system-unit-dir=/usr/lib/systemd/system \
                       -Dtests=false"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d

  # Disable session D-Bus dependent features
  cat > ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d/89-disable-session-dbus-dependent-features.conf << EOF
wireplumber.profiles = {
  main = {
    monitor.alsa.reserve-device = disabled
    default-access.enable-flatpak-portal = false
  }
}
EOF

  # Disable V4L2
  cat > ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d/89-disable-v4l2.conf << EOF
wireplumber.profiles = {
  main = {
    monitor.v4l2 = disabled
  }
}
EOF

  # Disable logind in BlueZ monitor
  cat > ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d/89-disable-bluez-logind.conf << EOF
wireplumber.profiles = {
  main = {
    monitor.bluez.seat-monitoring = disabled
  }
}
EOF

  # Configure BlueZ HFP/HSP backend
  cat > ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d/89-bluez-hfphsp-backend.conf << EOF
monitor.bluez.properties = {
  bluez5.hfphsp-backend = "none"
}
EOF

  # Configure BlueZ auto-connect
  cat > ${INSTALL}/usr/share/wireplumber/wireplumber.conf.d/50-bluez-config.conf << EOF
monitor.bluez.properties = {
  bluez5.auto-connect = [ hfp_hf hsp_hs a2dp_sink ]
}
EOF
}

post_install() {
  enable_service wireplumber.service
}

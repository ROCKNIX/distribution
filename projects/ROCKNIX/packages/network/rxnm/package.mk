# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rxnm"
PKG_VERSION="70eaf7c"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://codeberg.org/aenertia/rxnm"
PKG_URL="https://codeberg.org/aenertia/rxnm.git"
PKG_DEPENDS_TARGET="toolchain jq systemd iwd"
PKG_SECTION="network"
PKG_SHORTDESC="ROCKNIX Network Manager"
PKG_LONGDESC="rxnm — lightning-fast modular CLI suite for systemd-networkd, iwd, and bluez."
PKG_TOOLCHAIN="make"

make_target() {
  cd ${PKG_BUILD}
  mkdir -p bin build
  bash scripts/sync-constants.sh
  ${CC} ${CFLAGS} -std=c11 -Isrc -o bin/rxnm-agent src/rxnm-agent.c ${LDFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib/rocknix-network-manager/bin
  mkdir -p ${INSTALL}/usr/lib/rocknix-network-manager/lib
  mkdir -p ${INSTALL}/usr/lib/rocknix-network-manager/plugins

  cp -f ${PKG_BUILD}/bin/* ${INSTALL}/usr/lib/rocknix-network-manager/bin/
  cp -f ${PKG_BUILD}/lib/* ${INSTALL}/usr/lib/rocknix-network-manager/lib/
  chmod 755 ${INSTALL}/usr/lib/rocknix-network-manager/bin/*
  chmod 644 ${INSTALL}/usr/lib/rocknix-network-manager/lib/*

  # Create correct symlink for target filesystem
  ln -sf /usr/lib/rocknix-network-manager/bin/rxnm ${INSTALL}/usr/bin/rxnm

  # Systemd service units
  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_BUILD}/systemd/rxnm-roaming.service    ${INSTALL}/usr/lib/systemd/system/
  cp ${PKG_BUILD}/systemd/rxnm-api@.service       ${INSTALL}/usr/lib/systemd/system/
  cp ${PKG_BUILD}/systemd/rxnm-api.socket         ${INSTALL}/usr/lib/systemd/system/
  cp ${PKG_DIR}/system.d/rxnm.service             ${INSTALL}/usr/lib/systemd/system/

  # Default network templates for systemd-networkd
  mkdir -p ${INSTALL}/usr/lib/systemd/network
  cp ${PKG_BUILD}/usr/lib/systemd/network/*.network ${INSTALL}/usr/lib/systemd/network/

  # Suspend/resume hook
  mkdir -p ${INSTALL}/usr/lib/systemd/system-sleep
  cp ${PKG_BUILD}/usr/lib/systemd/system-sleep/rxnm-resume ${INSTALL}/usr/lib/systemd/system-sleep/

  # Bash completion
  mkdir -p ${INSTALL}/usr/share/bash-completion/completions
  cp ${PKG_BUILD}/usr/share/bash-completion/completions/rxnm ${INSTALL}/usr/share/bash-completion/completions/

  # ROCKNIX: iwd stores state in /storage/.cache/iwd (not FHS /var/lib/iwd)
  # Patch STATE_DIR default so rxnm writes PSK files where iwd reads them
  sed -i 's|STATE_DIR:=/var/lib|STATE_DIR:=/storage/.cache|' \
    ${INSTALL}/usr/lib/rocknix-network-manager/lib/rxnm-constants.sh

  # RAM-first architecture: /etc/systemd/network -> /run/systemd/network
  mkdir -p ${INSTALL}/etc/systemd
  ln -sf /run/systemd/network ${INSTALL}/etc/systemd/network
}

post_install() {
  enable_service rxnm.service
  # rxnm-roaming.service  — user-activated (WiFi roaming monitor)
  # rxnm-api.socket        — user-activated (JSON API on port 29304)
}

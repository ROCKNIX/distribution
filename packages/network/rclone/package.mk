# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Xargon (https://github.com/XargonWan)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="rclone"
PKG_VERSION="1.67.0"
PKG_DEPENDS_TARGET="toolchain fuse rsync"
PKG_LONGDESC="rsync for cloud storage"
PKG_TOOLCHAIN="manual"

case ${ARCH} in
    aarch64)
      RCLONE_ARCH="arm64"
    ;;
    *)
      RCLONE_ARCH="amd64"
    ;;
esac

PKG_URL="https://downloads.rclone.org/v${PKG_VERSION}/rclone-v${PKG_VERSION}-linux-${RCLONE_ARCH}.zip"
PKG_RCLONE="rclone-v${PKG_VERSION}-linux-${RCLONE_ARCH}/rclone"

unpack() {
  mkdir -p ${PKG_BUILD}
  mv ${SOURCES}/rclone/rclone-${PKG_VERSION}.zip ${SOURCES}/rclone/rclone-${PKG_VERSION}-${RCLONE_ARCH}.zip
  unzip ${SOURCES}/rclone/rclone-${PKG_VERSION}-${RCLONE_ARCH}.zip -d ${PKG_BUILD}/
  rm -f ${SOURCES}/rclone/rclone-${PKG_VERSION}*
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/
  mkdir -p ${INSTALL}/usr/config/
  cp rclonectl ${INSTALL}/usr/bin/
  cp cloud_backup ${INSTALL}/usr/bin/
  cp cloud_restore ${INSTALL}/usr/bin/
  cp ${PKG_BUILD}/${PKG_RCLONE} ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/*
  cp rsync-rules.conf ${INSTALL}/usr/config/
  cp rsync.conf ${INSTALL}/usr/config/
  cp cloud_sync-rules.txt ${INSTALL}/usr/config/
  cp cloud_sync.conf ${INSTALL}/usr/config/
  cp cloud_sync.conf.defaults ${INSTALL}/usr/config/
  chmod 755 ${INSTALL}/usr/bin/rclone
  mkdir -p ${INSTALL}/usr/config/modules
  ln -sf /usr/bin/cloud_backup ${INSTALL}/usr/config/modules/cloud_backup.sh
  ln -sf /usr/bin/cloud_restore ${INSTALL}/usr/config/modules/cloud_restore.sh
}

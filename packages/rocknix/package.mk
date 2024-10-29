# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="rocknix"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ROCKNIX Meta Package"
PKG_TOOLCHAIN="make"

make_target() {
  :
}

makeinstall_target() {

  mkdir -p ${INSTALL}/usr/config/
  rsync -av ${PKG_DIR}/config/* ${INSTALL}/usr/config/
  ln -sf /storage/.config/system ${INSTALL}/system
  find ${INSTALL}/usr/config/system/ -type f -exec chmod o+x {} \;

  mkdir -p ${INSTALL}/usr/bin/

  ### Compatibility links for ports
  ln -s /storage/roms ${INSTALL}/roms

  ### Add some quality of life customizations for hardworking devs.
  if [ -n "${LOCAL_SSH_KEYS_FILE}" ]
  then
    mkdir -p ${INSTALL}/usr/config/ssh
    cp ${LOCAL_SSH_KEYS_FILE} ${INSTALL}/usr/config/ssh/authorized_keys
  fi

  if [ -n "${LOCAL_WIFI_SSID}" ]
  then
    sed -i "s#network.enabled=0#network.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    cat <<EOF >> ${INSTALL}/usr/config/system/configs/system.cfg
wifi.ssid=${LOCAL_WIFI_SSID}
wifi.key=${LOCAL_WIFI_KEY}
EOF
  fi
}

post_install() {
  ln -sf rocknix.target ${INSTALL}/usr/lib/systemd/system/default.target

  if [ ! -d "${INSTALL}/usr/share" ]
  then
    mkdir "${INSTALL}/usr/share"
  fi
  cp ${PKG_DIR}/sources/post-update ${INSTALL}/usr/share
  chmod 755 ${INSTALL}/usr/share/post-update

  # Issue banner
  BUILD_ID=$(git rev-parse HEAD)
  cp ${PKG_DIR}/sources/issue ${INSTALL}/etc
  ln -sf /etc/issue ${INSTALL}/etc/motd
  cat <<EOF >> ${INSTALL}/etc/issue
... Version: ${OS_VERSION}-${OS_BUILD} (${BUILD_ID:0:7})
... Built: ${BUILD_DATE}

EOF

  cp ${PKG_DIR}/sources/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/* 2>/dev/null ||:

  ### Fix and migrate to autostart package
  enable_service rocknix-autostart.service

  ### Take a backup of the system configuration on shutdown
  enable_service save-sysconfig.service

  sed -i "s#@DEVICENAME@#${DEVICE}#g" ${INSTALL}/usr/config/system/configs/system.cfg

  ### Defaults for non-main builds.
  BUILD_BRANCH="$(git branch --show-current)"
  if [ ! "${BUILD_BRANCH}" = "main" ]
  then
    sed -i "s#samba.enabled=0#samba.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#ssh.enabled=0#ssh.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#network.enabled=0#network.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#system.loglevel=none#system.loglevel=verbose#g" ${INSTALL}/usr/config/system/configs/system.cfg
  fi

  ### Disable automount on AMD64
  if [ "${DEVICE}" = "AMD64" ]
  then
    sed -i "s#system.automount=1#system.automount=0#g" ${INSTALL}/usr/config/system/configs/system.cfg
  fi

}

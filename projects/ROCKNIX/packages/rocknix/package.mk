# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="rocknix"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
# zip is a *runtime* dependency of the backuptool script, so nothing failed
# at build time when upstream dropped the package (a3d0ad0430) -- the image
# simply shipped without it and "backuptool backup" could not run. Declaring
# it here turns an invisible runtime dependency into one the build enforces.
PKG_DEPENDS_TARGET="toolchain autostart zip"
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
    sed -i "s#wifi.enabled=0#wifi.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    mkdir -p ${INSTALL}/usr/config/iwd
    cat <<EOF >> ${INSTALL}/usr/config/iwd/${LOCAL_WIFI_SSID}.psk
[Security]
Passphrase=${LOCAL_WIFI_KEY}
EOF
  fi
  # Always install the update script
  mkdir -p $INSTALL/usr/share/bootloader
  # A device without an in-place bootloader updater ships none: GENERIC_X64's
  # copied nothing and was removed (#307 PL-073). A bare `a && b` as the
  # function's last statement returns a's failure and fails the install.
  if find_file_path bootloader/update.sh; then
    cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
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
  cat <<EOF >> ${INSTALL}/etc/issue
... Version: ${OS_VERSION} (${OS_BUILD})
... Built: ${BUILD_DATE}

EOF
  cp ${PKG_DIR}/sources/motd ${INSTALL}/etc
  cat ${INSTALL}/etc/issue >> ${INSTALL}/etc/motd

  cp ${PKG_DIR}/sources/scripts/* ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/* 2>/dev/null ||:

  ### Fix and migrate to autostart package
  enable_service rocknix-autostart.service

  ### ZRAM/Swap and Memory Manager Service
  enable_service rocknix-memory-manager.service

  ### Take a backup of the system configuration on shutdown
  enable_service save-sysconfig.service
  # what the device looked like before it froze, kept on /storage (fork #104)
  enable_service rocknix-evidence.timer

  ### Put system.cfg right (from its last good copy) before the hostname is read
  enable_service rocknix-sysconfig.service

  sed -i "s#@DEVICENAME@#${DEVICE}#g" ${INSTALL}/usr/config/system/configs/system.cfg

  ### Defaults for community builds.
  if [ "${OS_BUILD}" = "community" ]
  then
    sed -i "s#samba.enabled=0#samba.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#ssh.enabled=0#ssh.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#wifi.enabled=0#wifi.enabled=1#g" ${INSTALL}/usr/config/system/configs/system.cfg
    sed -i "s#system.loglevel=none#system.loglevel=verbose#g" ${INSTALL}/usr/config/system/configs/system.cfg
  fi

  ### Disable automount on AMD64
  if [ "${DEVICE}" = "AMD64" ]
  then
    sed -i "s#system.automount=1#system.automount=0#g" ${INSTALL}/usr/config/system/configs/system.cfg
  fi

  ### Enable HDMI hotplug service on H700
  if [ "${DEVICE}" = "H700" ]
  then
    enable_service hdmi-hotplug.path
  fi

  ### Remove different arch freq functions
  if [ "${TARGET_ARCH}" = "x86_64" ]; then
    rm -rf ${INSTALL}/etc/profile.d/099-freqfunctions
  else
    rm -rf ${INSTALL}/etc/profile.d/100-amd64-freqfunctions
  fi
}

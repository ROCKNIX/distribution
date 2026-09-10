# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="modules"
PKG_VERSION="1.0"
PKG_LICENSE="custom"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain rclone commander qterminal"
PKG_LONGDESC="OS Modules Package"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  RK3399|RK3588|SM8250|SM8550|SM8650|SM8750|SM6115)
    PKG_DEPENDS_TARGET+=" gamepadtester"
    ;;
esac

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/modules
    cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/modules
}

post_makeinstall_target() {
  if [[ "${CODEX_SUPPORT}" != "yes" ]]; then
    sed -i \
      -e '/<path>\.\/Install Codex\.sh<\/path>/,/<\/game>/d' \
      -e '/<path>\.\/Start Codex\.sh<\/path>/,/<\/game>/d' \
      ${INSTALL}/usr/config/modules/gamelist.xml
  fi

  case ${DEVICE} in
    SM8650|SM8750) rm -f ${INSTALL}/usr/config/modules/*32bit* ;;
  esac

  if [[ "${INSTALLER_SUPPORT}" != "yes" || "${DISPLAYSERVER}" != "wl" ]]; then
    rm -f ${INSTALL}/usr/config/modules/Install*
  fi
}

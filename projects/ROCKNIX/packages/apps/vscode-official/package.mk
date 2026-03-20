# SPDX-License-Identifier: LicenseRef-Proprietary-Microsoft

PKG_NAME="vscode-official"
PKG_VERSION="1.99.0"
PKG_SHA256="5fd9574d2d0bd30f64bcb74c8326167d523fd5ad49554b276e5491f0e1ba0c91"
PKG_LICENSE="Proprietary"
PKG_SITE="https://code.visualstudio.com/"
PKG_SOURCE_NAME="vscode-linux-arm64-${PKG_VERSION}.tar.gz"
# Pin this to the exact verified archive used for the target image build.
PKG_URL="https://update.code.visualstudio.com/${PKG_VERSION}/linux-arm64/stable"
PKG_DEPENDS_TARGET="toolchain sway rocknix-touchscreen-keyboard"
PKG_LONGDESC="Official Microsoft Visual Studio Code desktop build for Linux arm64 on ROCKNIX."
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/vscode-official
  rsync -a \
    --exclude '.rocknix-*' \
    --exclude 'Start VS Code.sh' \
    ${PKG_BUILD}/ ${INSTALL}/usr/lib/vscode-official/

  mkdir -p ${INSTALL}/usr/bin
  cp -f ${PKG_DIR}/scripts/vscode-official.sh ${INSTALL}/usr/bin/vscode-official
  chmod 0755 ${INSTALL}/usr/bin/vscode-official
  ln -sf /usr/bin/vscode-official ${INSTALL}/usr/bin/code

  mkdir -p ${INSTALL}/usr/config/vscode-official/User
  cp -rf ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/vscode-official/User/

  mkdir -p ${INSTALL}/usr/config/modules
  cp -f "${PKG_DIR}/sources/Start VS Code.sh" "${INSTALL}/usr/config/modules/Start VS Code.sh"
  chmod 0755 "${INSTALL}/usr/config/modules/Start VS Code.sh"
}

# Likely dependency expansion pass for the real tree:
# - Review Electron runtime needs on Thor Wayland before locking deps.
# - Verify whether gtk, nss, nspr, mesa, libxkbcommon, and audio stack packages
#   are already covered transitively by the target image.
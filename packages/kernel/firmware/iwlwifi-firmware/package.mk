PKG_NAME="iwlwifi-firmware"
PKG_VERSION="6faef0d76cff4f2f6082b6a22245341fcb4f469e"
PKG_LICENSE="Apache"
PKG_SITE="https://github.com/armbian/firmware"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="iwlwifi Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware
    cp -av iwlwifi-*.ucode ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware
}

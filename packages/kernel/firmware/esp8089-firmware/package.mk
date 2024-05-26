PKG_NAME="esp8089-firmware"
PKG_VERSION="490722a"
PKG_LICENSE="Apache"
PKG_SITE="https://github.com/armbian/firmware"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="esp8089 Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware
    cp -av eagle_fw*.bin ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware
}

PKG_NAME="ibt-firmware"
PKG_VERSION="6faef0d76cff4f2f6082b6a22245341fcb4f469e"
PKG_SHA256="7e4bc0763358f85e308ea0b4a46f08e84ae4e480c7665d5112fbee34200b5623"
PKG_LICENSE="Apache"
PKG_SITE="https://github.com/armbian/firmware"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ibt Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/intel
    cp -av intel/ibt-* ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/intel
}

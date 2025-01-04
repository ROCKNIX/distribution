PKG_NAME="potator-lr"
PKG_VERSION="735bc376974be564045356188a3b899f2b6fedbd"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/potator"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A Watara Supervision Emulator based on Normmatt version."
PKG_TOOLCHAIN="make"


make_target() {
  make -C platform/libretro/ platform=aarch64
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp platform/libretro/potator_libretro.so ${INSTALL}/usr/lib/libretro/
}

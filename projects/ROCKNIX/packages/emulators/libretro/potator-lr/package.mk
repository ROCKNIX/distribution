PKG_NAME="potator-lr"
PKG_VERSION="ad87bc6068ef126e48339b440465fb0bf5a2794f"
PKG_SHA256="a863462780ac042ad1a8defe1ab3e864fde060c645d605de3661962b72c4b808"
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

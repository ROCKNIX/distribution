# SPDX-License-Identifier: GPL-2.0-only

PKG_NAME="AW87391"
PKG_VERSION="1.0"
PKG_LICENSE="GPL-2.0-only"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="AW87391 minimal speaker amp driver (local source)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"
PKG_DEPENDS_TARGET="toolchain linux"

pre_make_target() {
  unset LDFLAGS

  if [ ! -f "${PKG_BUILD}/Makefile" ]; then
    cat <<'EOF' > "${PKG_BUILD}/Makefile"
obj-m += aw87391.o
EOF
  fi
}

make_target() {
  kernel_make -C "$(kernel_path)" M="${PKG_BUILD}"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/$(get_full_module_dir)/${PKG_NAME}"
  cp *.ko "${INSTALL}/$(get_full_module_dir)/${PKG_NAME}"
}

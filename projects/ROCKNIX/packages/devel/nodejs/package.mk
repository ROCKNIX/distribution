# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="nodejs"
PKG_VERSION="v22.22.3"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nodejs/node"
PKG_URL="${PKG_SITE}/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain bzip2:host"
PKG_LONGDESC="Open-source, cross-platform JavaScript runtime environment."
PKG_TOOLCHAIN="configure"

pre_build_target() {
	mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
	cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

pre_build_host() {
	mkdir -p ${PKG_BUILD}/.${HOST_NAME}
	cp -RP ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}
}

configure_target() {
	case ${ARCH} in
		aarch64)
			PKG_ARCH_NAME_NODEJS="arm64"
		;;
		arm)
			PKG_ARCH_NAME_NODEJS="arm"
		;;
		x86_64)
			PKG_ARCH_NAME_NODEJS="x86_64"
		;;
	esac

	export CC_target=${TARGET_NAME}-gcc
  	export CXX_target=${TARGET_NAME}-g++
	export AR_target=${TARGET_NAME}-ar
	export LD_target=${TARGET_NAME}-ld

	export CC_host=/usr/bin/gcc
  	export CXX_host=/usr/bin/g++
	export AR_host=/usr/bin/ar
	export LD_host=/usr/bin/ld

  	/usr/bin/python3 ./configure.py \
		--cross-compiling \
		--dest-cpu ${PKG_ARCH_NAME_NODEJS} \
		--shared \
		--prefix /usr
}

configure_host() {
	/usr/bin/python3 ./configure.py \
		--shared \
		--prefix ${TOOLCHAIN}
}

post_makeinstall_host() {
	mkdir -p ${TOOLCHAIN}/usr/{lib,bin,include}
}
# SPDX-License-Identifier: GPL-2.0

PKG_NAME="umtprd"
PKG_VERSION="1.6.8"
PKG_SHA256="e0b3c308016595a5d956eaaa086d3bfe4c9af2270857181695338df9affb3574"
PKG_LICENSE="GPL-3.0+"
PKG_SITE="https://github.com/viveris/uMTP-Responder/"
PKG_URL="https://github.com/viveris/uMTP-Responder/archive/umtprd-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Lightweight USB Media Transfer Protocol (MTP) responder daemon for GNU/Linux"
PKG_TOOLCHAIN="make"

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/sbin/
	cp umtprd ${INSTALL}/usr/sbin/
	chmod 755 ${INSTALL}/usr/sbin/umtprd
	mkdir -p ${INSTALL}/etc/umtprd
	cp ${PKG_DIR}/etc/umtprd.conf ${INSTALL}/etc/umtprd
}

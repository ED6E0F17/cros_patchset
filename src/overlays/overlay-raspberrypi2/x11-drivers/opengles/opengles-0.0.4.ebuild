# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# Copyright 1999-2015 Gentoo Foundation (media-libs/raspberrpi-userland)

EAPI=4

CROS_WORKON_REPO="git://github.com/raspberrypi"
CROS_WORKON_PROJECT="userland"
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="fb11b39d97371c076eef7c85bbcab5733883a41e"

inherit git-2 cros-workon cmake-utils

DESCRIPTION="OpenGLES libraries for Raspberry Pi"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="arm"
IUSE=""

DEPEND=""
RDEPEND="!x11-drivers/opengles-bin"

src_unpack() {
	cros-workon_src_unpack
	cd "${S}"
	epatch "${FILESDIR}/piglit.patch"
}

src_configure() {
	tc-export CC CXX LD AR RANLIB NM
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}


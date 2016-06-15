# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit eutils toolchain-funcs
if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="svn://flashrom.org/flashrom/trunk"
	inherit subversion
else
	SRC_URI="http://download.flashrom.org/releases/${P}.tar.bz2"
	KEYWORDS="arm64 arm x86"
fi

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="http://flashrom.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="atahpt +bitbang_spi +buspirate_spi +dediprog doc +drkaiser
+dummy ft2232_spi +gfxnvidia +internal +nic3com +nicintel +nicintel_spi
nicnatsemi nicrealtek +ogp_spi rayer_spi
+pony_spi +satasii satamv +serprog +wiki"

COMMON_DEPEND="atahpt? ( sys-apps/pciutils )
	dediprog? ( virtual/libusb:0 )
	drkaiser? ( sys-apps/pciutils )
	ft2232_spi? ( dev-embedded/libftdi:0 )
	gfxnvidia? ( sys-apps/pciutils )
	internal? ( sys-apps/pciutils )
	nic3com? ( sys-apps/pciutils )
	nicintel? ( sys-apps/pciutils )
	nicintel_spi? ( sys-apps/pciutils )
	nicnatsemi? ( sys-apps/pciutils )
	nicrealtek? ( sys-apps/pciutils )
	rayer_spi? ( sys-apps/pciutils )
	satasii? ( sys-apps/pciutils )
	satamv? ( sys-apps/pciutils )
	ogp_spi? ( sys-apps/pciutils )"
RDEPEND="${COMMON_DEPEND}
	internal? ( sys-apps/dmidecode )"
DEPEND="${COMMON_DEPEND}
	sys-apps/diffutils"

_flashrom_enable() {
	local c="CONFIG_${2:-$(echo $1 | tr [:lower:] [:upper:])}"
	args+=" $c=$(usex $1 yes no)"
}
flashrom_enable() {
	local u
	for u in "$@" ; do _flashrom_enable $u ; done
}
src_configure() {
	echo "disabled"
}
src_compile() {
	 echo "disabled"
}
src_install() {
	 echo "disabled"
}

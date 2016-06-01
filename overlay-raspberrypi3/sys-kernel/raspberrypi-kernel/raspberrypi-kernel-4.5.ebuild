# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_REPO="git://github.com/zeldin"
CROS_WORKON_PROJECT="linux"
CROS_WORKON_EGIT_BRANCH="rpi3"
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="9171809a953d2afe25f36ca5c069b0e6f2ad7e0e"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit git-2 cros-kernel2 cros-workon

DESCRIPTION="Chrome OS Kernel for Raspberry Pi2"
KEYWORDS="arm64"

DEPEND="!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel
"
RDEPEND="${DEPEND}"

src_install() {
	cros-kernel2_src_install

	insinto /firmware/rpi
	newins "$(cros-workon_get_build_dir)/arch/arm64/boot/zImage" "kernel8.img"
	doins "${FILESDIR}"/{cmdline,config}.txt
	doins "$(cros-workon_get_build_dir)/arch/arm64/boot/dts/bcm2710-rpi-3-b.dtb"
	doins -r "$(cros-workon_get_build_dir)/arch/arm64/boot/dts/overlays"
}

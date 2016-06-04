# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_REPO="git://github.com/anholt"
CROS_WORKON_PROJECT="linux"
CROS_WORKON_EGIT_BRANCH="bcm2837-64-next"
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="a1955c6717a9c58d982d99be9b6fb01a50a7d83b"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit git-2 cros-kernel2 cros-workon

DESCRIPTION="Chrome OS Arm64 Kernel for Raspberry Pi3"
KEYWORDS="arm64"

DEPEND="!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel
"
RDEPEND="${DEPEND}"

src_install() {
	cros-kernel2_src_install

	insinto /firmware/rpi
	newins "$(cros-workon_get_build_dir)/arch/arm64/boot/Image" "kernel8.img"
	doins "${FILESDIR}"/{cmdline,config}.txt
	doins "$(cros-workon_get_build_dir)/arch/arm64/boot/dts/broadcom/bcm2837-rpi-3-b.dtb"
#	doins -r "$(cros-workon_get_build_dir)/arch/arm64/boot/dts/overlays"
}

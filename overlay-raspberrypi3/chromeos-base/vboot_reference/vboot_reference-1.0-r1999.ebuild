# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="05cd8ce75f97a76c4ef155734d191cd275bac231"
CROS_WORKON_TREE="92b9b7ba98aa165f57ca7f29729435fef3e10db4"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon cros-au

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au cros_host dev_debug_force minimal -mtd pd_sync tpmtests"

RDEPEND="!minimal? ( dev-libs/libyaml )
	mtd? ( sys-apps/flashrom )
	dev-libs/openssl
	sys-apps/util-linux"
DEPEND="mtd? ( dev-embedded/android_mtdutils )
	${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

_src_compile_main() {
	mkdir "${WORKDIR}"/build-main
	tc-export CC AR CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	# Vboot reference knows the flags to use
	unset CFLAGS
	emake BUILD="${WORKDIR}"/build-main \
	      ARCH=arm \
	      PD_SYNC=$(usev pd_sync) \
	      USE_MTD=$(usev mtd) \
	      MINIMAL=$(usev minimal) all
	unset CC AR CXX PKG_CONFIG
}

_src_compile_au() {
	board_setup_32bit_au_env
	mkdir "${WORKDIR}"/build-au
	einfo "Building 32-bit library for installer to use"
	tc-export CC AR CXX PKG_CONFIG
	emake BUILD="${WORKDIR}"/build-au/ \
	      ARCH=arm \
	      PD_SYNC=$(usev pd_sync) \
	      USE_MTD=$(usev mtd) \
	      MINIMAL=$(usev minimal) tinyhostlib
	unset CC AR CXX PKG_CONFIG
	board_teardown_32bit_au_env
}

src_compile() {
	_src_compile_main
	use 32bit_au && _src_compile_au
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0
	emake BUILD="${WORKDIR}"/build-main \
	      SRCDIR="${S}" \
	      ARCH=arm \
	      PD_SYNC=$(usev pd_sync) \
	      MINIMAL=$(usev minimal) runtests
}

src_install() {
	einfo "Installing programs"
	if use minimal ; then
		# Installing on the target
		emake BUILD="${WORKDIR}"/build-main DESTDIR="${D}" \
		      LIBDIR="$(get_libdir)" \
		      PD_SYNC=$(usev pd_sync) \
		      DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		      USE_MTD=$(usev mtd) \
		      MINIMAL=1 install$(usex mtd "_mtd" "")
	else
		# Installing on the host
		emake BUILD="${WORKDIR}"/build-main DESTDIR="${D}/usr" \
		      LIBDIR="$(get_libdir)" \
		      PD_SYNC=$(usev pd_sync) \
		      DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		      USE_MTD=$(usev mtd) \
		      install

		insinto /usr/share/vboot/bin
		doins scripts/image_signing/convert_recovery_to_ssd.sh
		doins scripts/image_signing/common_minimal.sh
	fi

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "${WORKDIR}"/build-main/tests/tpm_lite/tpmtest*[^.]?
		dobin "${WORKDIR}"/build-main/utility/tpm_set_readsrkpub
	fi

	# Install devkeys to /usr/share/vboot/devkeys
	# (shared by host and target)
	einfo "Installing devkeys"
	insinto /usr/share/vboot/devkeys
	doins tests/devkeys/*

	# Install public headers to /build/${BOARD}/usr/include/vboot
	einfo "Installing header files"
	insinto /usr/include/vboot
	doins host/include/* \
	      firmware/include/gpt.h \
	      firmware/include/tlcl.h \
	      firmware/include/tss_constants.h

	einfo "Installing host library"
	dolib.a "${WORKDIR}"/build-main/libvboot_host.a

	# Install 32-bit library needed by installer programs.
	if use 32bit_au; then
		einfo "Installing 32-bit host library"
		insopts -m0644
		insinto /usr/lib/vboot32
		doins "${WORKDIR}"/build-au/libvboot_host.a
	fi
}

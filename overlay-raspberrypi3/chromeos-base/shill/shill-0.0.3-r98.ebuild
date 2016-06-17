# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("e9a281eb8aae85445304ce06c1f0384cb1e5d45c" "25d0a0ea4ae89ea08d1c596473e3699373f984ae")
CROS_WORKON_TREE=("f2c41beb7e131949017635acabe7bf0f36ed1de9" "71959108f3e35380125ea9e8779477bd9c634e13")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/connectivity/shill")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/shill")
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="shill"

inherit cros-workon platform udev user

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD-Google"
SLOT="0"
IUSE="+cellular dhcpv6 json_store pppoe +seccomp test +tpm +vpn wake_on_wifi +wifi wimax +wired_8021x"
KEYWORDS="*"

# Sorted by the package we depend on. (Not by use flag!)
RDEPEND="
	chromeos-base/bootstat
	tpm? ( chromeos-base/chaps )
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/nsswitch
	wimax? ( chromeos-base/wimax_manager )
	dev-libs/dbus-c++
	cellular? ( net-dialup/ppp )
	pppoe? ( net-dialup/ppp )
	vpn? ( net-dialup/ppp )
	net-dns/c-ares
	net-firewall/iptables
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	net-misc/dhcpcd
	dhcpv6? ( net-misc/dhcpcd[ipv6] )
	vpn? ( net-misc/openvpn )
	wifi? ( net-wireless/wpa_supplicant[dbus] )
	wired_8021x? ( net-wireless/wpa_supplicant[dbus] )
	sys-apps/rootdev
	cellular? ( virtual/modemmanager )
"

DEPEND="${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/shill-client
	chromeos-base/power_manager-client
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

pkg_preinst() {
	enewgroup "shill-crypto"
	enewuser "shill-crypto"
	enewgroup "nfqueue"
	enewuser "nfqueue"
}

get_dependent_services() {
	local dependent_services=()
	if use wifi || use wired_8021x; then
		dependent_services+=(wpasupplicant)
	fi
	echo "started network-services ${dependent_services[*]/#/and started }"
}

load_cfg80211() {
	if use wifi; then
		echo "modprobe cfg80211"
	else
		echo true
	fi
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/shill"
}

src_install() {
	# Install libshill-net library.
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		./net/preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libshill-net-${v}.so"
		doins "${OUT}/lib/libshill-net-${v}.pc"
	done

	# Install header files from libshill-net.
	insinto /usr/include/shill/net
	doins net/*.h

	dobin bin/ff_debug

	if use cellular; then
		dobin bin/set_apn
		dobin bin/set_cellular_ppp
	fi

	dosbin bin/reload_network_device
	dosbin bin/set_wifi_regulatory
	dobin bin/set_arpgw
	dobin bin/set_wake_on_lan
	dobin bin/shill_login_user
	dobin bin/shill_logout_user
	if use wifi || use wired_8021x; then
		dobin bin/wpa_debug
	fi
	dobin "${OUT}"/shill

	# Netfilter queue helper is run directly from init, so install in sbin.
	dosbin "${OUT}"/netfilter-queue-helper
	dosbin init/netfilter-common

	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	use seccomp && newins shims/nfqueue-seccomp-arm.policy nfqueue-seccomp.policy

	local shims_dir=/usr/$(get_libdir)/shill/shims
	exeinto "${shims_dir}"
	doexe "${OUT}"/crypto-util

	use vpn && doexe "${OUT}"/openvpn-script
	if use cellular || use pppoe || use vpn; then
		newexe "${OUT}"/lib/libshill-pppd-plugin.so shill-pppd-plugin.so
	fi

	use cellular && doexe "${OUT}"/set-apn-helper

	if use wifi || use wired_8021x; then
		sed \
			"s,@libdir@,/usr/$(get_libdir)", \
			shims/wpa_supplicant.conf.in \
			> "${D}/${shims_dir}/wpa_supplicant.conf"
	fi

	dosym /var/run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf
	insinto /usr/share/shill
	use cellular && doins "${OUT}"/serviceproviders.pbf

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.dbus-xml

	# Install init scripts
	insinto /etc/init
	doins init/*.conf
	sed \
		"s,@expected_started_services@,$(get_dependent_services)," \
		init/shill.conf.in \
		> "${D}/etc/init/shill.conf"
	sed \
		"s,@load_cfg80211@,$(load_cfg80211)," \
		init/network-services.conf.in \
		> "${D}/etc/init/network-services.conf"

	udev_dorules udev/*.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/shill_unittest"
}

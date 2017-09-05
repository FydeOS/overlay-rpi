# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_REPO="https://github.com/raspberrypi"
CROS_WORKON_PROJECT="linux"
CROS_WORKON_EGIT_BRANCH="rpi-4.9.y"
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="84a1781639429747b894f5121476b514a6a20651"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit git-2 cros-kernel2 cros-workon

DESCRIPTION="Chrome OS Kernel- RPI"
KEYWORDS="arm"
KERNEL="kernel7"

DEPEND="!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel
"
RDEPEND="${DEPEND}"

src_install() {
	cros-kernel2_src_install
	"${D}/../work/raspberrypi-kernel-4.9/scripts/mkknlimg" \
				"$(cros-workon_get_build_dir)/arch/arm/boot/zImage" \
                "${T}/kernel.img"

	insinto /firmware/rpi
	doins "${FILESDIR}"/{cmdline,config}.txt
	doins "${T}/kernel.img"
}

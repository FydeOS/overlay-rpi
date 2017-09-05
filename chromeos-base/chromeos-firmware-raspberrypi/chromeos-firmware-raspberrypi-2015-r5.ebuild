# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Firmware"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="arm"
IUSE=""
RESTRICT="mirror"

S=${WORKDIR}

FW_REV="stable"

SRC_URI="https://github.com/raspberrypi/firmware/archive/${FW_REV}.zip -> firmware.zip
	https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.bin
	https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.txt"

src_install() {
	cd "firmware-stable/boot"
	insinto /firmware/rpi
	#insinto /boot
	#doins fixup.dat start.elf bootcode.bin
	doins *.dtb *.bin *.linux LICENCE.* *.linux *.elf *.dat
	cd "overlays"
	insinto /firmware/rpi/overlays
	#insinto /boot/overlays
	doins *.*

	# Install WiFi firmware.
	insinto /lib/firmware/brcm
	doins ${DISTDIR}/brcmfmac43430-sdio.bin
	doins ${DISTDIR}/brcmfmac43430-sdio.txt	
}

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e2b3a0605aee0d9bde24c8167a5adeea1975a869"
CROS_WORKON_TREE="d57c7fbb2c88b4b25d4ea09d3d77b35d76dd5a48"
CROS_WORKON_PROJECT="chromiumos/platform/minigbm"
CROS_WORKON_LOCALNAME="../platform/minigbm"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="Mini GBM implementation"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
VIDEO_CARDS="amdgpu exynos intel marvell mediatek rockchip tegra vc4"
IUSE="-asan -clang"
for card in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${card}"
done
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	x11-libs/libdrm
	!media-libs/mesa[gbm]
	video_cards_amdgpu? ( media-libs/amdgpu-addrlib )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch ${FILESDIR}/Makefile_vc4.patch
	cros-workon_src_prepare
}

src_configure() {
	export LIBDIR="/usr/$(get_libdir)"
	use video_cards_exynos && append-cppflags -DDRV_EXYNOS && export DRV_EXYNOS=1
	use video_cards_intel && append-cppflags -DDRV_I915 && export DRV_I915=1
	use video_cards_marvell && append-cppflags -DDRV_MARVELL && export DRV_MARVELL=1
	use video_cards_mediatek && append-cppflags -DDRV_MEDIATEK && export DRV_MEDIATEK=1
	use video_cards_rockchip && append-cppflags -DDRV_ROCKCHIP && export DRV_ROCKCHIP=1
	use video_cards_tegra && append-cppflags -DDRV_TEGRA && export DRV_TEGRA=1
	use video_cards_vc4 && append-cppflags -DDRV_VC4 && export DRV_VC4=1
	use video_cards_amdgpu && append-cppflags -DDRV_AMDGPU && export DRV_AMDGPU=1
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install

	insinto "${EPREFIX}/etc/udev/rules.d"
	doins "${FILESDIR}/50-vgem.rules"

	default
}

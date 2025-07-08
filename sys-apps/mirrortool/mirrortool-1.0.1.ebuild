# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy3_11 python3_{11..13} )
PYTHON_REQ_USE='threads(+)'

inherit meson linux-info python-r1

DESCRIPTION="Fetch tool for mirroring"
HOMEPAGE="https://github.com/MeRkyLeZ/mirrortool"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	GIT_REPO_URI="https://github.com/MeRkyLeZ/mirrortool.git"
else
	SRC_URI="https://github.com/MeRkyLeZ/mirrortool/archive/${PV}.tar.gz
		-> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="+native-extensions test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

BDEPEND="
	${PYTHON_DEPS}
	>=app-arch/tar-1.27
	>=dev-build/meson-1.3.0-r1
	>=sys-apps/sed-4.0.5
	sys-devel/patch
	test? (
		dev-python/pytest-xdist[${PYTHON_USEDEP}]
		dev-vcs/git
	)
"
RDEPEND="
	${PYTHON_DEPS}
	sys-apps/portage
"
PDEPEND="
"

pkg_pretend() {
	local CONFIG_CHECK="~IPC_NS ~PID_NS ~NET_NS ~UTS_NS"

	check_extra_config
}

src_prepare() {
	default
}

src_configure() {
	local code_only=false
	python_foreach_impl my_src_configure
}

my_src_configure() {
	local emesonargs=(
		-Dcode-only=${code_only}
		-Deprefix="${EPREFIX}"
		-Dmirrortool-bindir="${EPREFIX}/usr/lib/mirrortool/${EPYTHON}"
	)

	if use native-extensions && [[ "${EPYTHON}" != pypy3* ]] ; then
		emesonargs+=( -Dnative-extensions=true )
	else
		emesonargs+=( -Dnative-extensions=false )
	fi

	meson_src_configure
	code_only=true
}

src_compile() {
	python_foreach_impl meson_src_compile
}

src_test() {
	local EPYTEST_XDIST=1
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	python_foreach_impl epytest
}

src_install() {
    python_foreach_impl my_src_install

    local scripts
	#mapfile -t scripts < <(awk '/^#!.*python/ {print FILENAME} {nextfile}' "${ED}"/usr/{bin,sbin}/* || die)
	mapfile -t scripts < <(awk '/^#!.*python/ {print FILENAME} {nextfile}' "${ED}"/usr/{bin,sbin}/*)
	python_replicate_script "${scripts[@]}"
}

my_src_install() {
	local pydirs=(
		"${D}$(python_get_sitedir)"
		"${ED}/usr/lib/portage/${EPYTHON}"
	)

	meson_src_install
	#python_fix_shebang "${pydirs[@]}"
	python_optimize "${pydirs[@]}"
}

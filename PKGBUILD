# shellcheck shell=bash
# makepkg consumes the metadata and sets the package directories.
# shellcheck disable=SC2034,SC2154
# Maintainer: Marius Fanu <fanumarius@gmail.com>
# Binary package. It downloads the public release and installs files under /usr.
# The install script starts the agent, opens the command port, and puts the pill on the bar.
pkgname=nudgelan-agent-bin
pkgver=2.2.0
pkgrel=1
pkgdesc='Linux companion for NudgeLAN, a local-network utility for device discovery and remote wake/control actions.'
arch=('x86_64')
url='https://github.com/mariusfanu/nudgelan-agent-bin'
license=('MIT')
depends=('avahi' 'gcc-libs' 'glibc' 'python' 'polkit' 'iproute2' 'ufw' 'jq' 'omarchy'
         'curl' 'gnupg' 'libarchive')
provides=("nudgelan-agent=$pkgver")
conflicts=('nudgelan-agent')
options=('!strip' '!debug')
install=nudgelan-agent.install
source=("$url/releases/download/v$pkgver/nudgelan-agent-$pkgver-x86_64.tar.gz")
# The release script sets this checksum when it stages the tarball.
sha256sums=('f3a27f3586a0c3b74109a481bb1b5f9d9dd2107d5dc9f0ffbc137b556f01b802')

package() {
  cd "$srcdir/nudgelan-agent-$pkgver-x86_64" || return
  sh "$srcdir/nudgelan-agent-$pkgver-x86_64/install-tree" . "$pkgdir"
}

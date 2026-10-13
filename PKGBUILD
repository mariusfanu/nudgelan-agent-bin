# Maintainer: Marius Fanu <fanumarius@gmail.com>
# Binary package. It downloads the public release and installs files under /usr.
# The install script starts the agent, opens the command port, and puts the pill on the bar.
pkgname=nudgelan-agent-bin
pkgver=1.0.0
pkgrel=1
pkgdesc='Linux companion for NudgeLAN, a local-network utility for device discovery and remote wake/control actions.'
arch=('x86_64')
url='https://github.com/mariusfanu/nudgelan-agent-bin'
license=('MIT')
depends=('avahi' 'gcc-libs' 'glibc' 'python' 'polkit' 'iproute2' 'ufw' 'jq' 'omarchy')
provides=("nudgelan-agent=$pkgver")
conflicts=('nudgelan-agent')
options=('!strip' '!debug')
install=nudgelan-agent.install
source=("$url/releases/download/v$pkgver/nudgelan-agent-$pkgver-x86_64.tar.gz")
sha256sums=('da47329f78c35f1a1825cb461bc8a7f920f64a818c80633eaec459361d1a79a0')

package() {
  cd "nudgelan-agent-$pkgver-x86_64"
  install -Dm755 nudgelan-agent "$pkgdir/usr/bin/nudgelan-agent"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 systemd/nudgelan-agent.service \
    "$pkgdir/usr/lib/systemd/user/nudgelan-agent.service"
  sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/nudgelan-agent|' \
    "$pkgdir/usr/lib/systemd/user/nudgelan-agent.service"
  install -Dm644 packaging/polkit/10-nudgelan.rules \
    "$pkgdir/usr/share/polkit-1/rules.d/10-nudgelan.rules"
  install -Dm755 packaging/nudgelan-firewall "$pkgdir/usr/bin/nudgelan-firewall"
  install -Dm755 packaging/nudgelan-firewall-apply \
    "$pkgdir/usr/lib/nudgelan/nudgelan-firewall-apply"
  install -Dm755 packaging/nudgelan-firewall-configure \
    "$pkgdir/usr/lib/nudgelan/nudgelan-firewall-configure"
  install -Dm644 packaging/polkit/io.github.mariusfanu.nudgelan.firewall.policy \
    "$pkgdir/usr/share/polkit-1/actions/io.github.mariusfanu.nudgelan.firewall.policy"
  local plugin="$pkgdir/usr/share/nudgelan/plugins/io.github.mariusfanu.nudgelan"
  install -d "$plugin"
  cp -a plugins/io.github.mariusfanu.nudgelan/. "$plugin/"
}

#!/bin/bash
# Install NudgeLAN on Omarchy. Run from a desktop terminal:
#   bash <(curl -fsSL https://github.com/mariusfanu/nudgelan-agent-bin/releases/latest/download/install.sh)
set -euo pipefail

repo_slug=mariusfanu/nudgelan-agent-bin

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your desktop user. The script asks for your password when it needs root." >&2
  exit 1
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -S "${XDG_RUNTIME_DIR}/bus" ]; then
  echo "Log into the Omarchy desktop and run this in a terminal there." >&2
  exit 1
fi

echo "NudgeLAN install started."
tag=$(curl -fsSL "https://api.github.com/repos/${repo_slug}/releases/latest" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
echo "Using release ${tag}."

sudo -v
echo "Installing build tools..."
sudo pacman -S --needed --noconfirm base-devel git

dest="${XDG_DATA_HOME:-$HOME/.local/share}/nudgelan-agent-bin"
rm -rf "$dest"
echo "Downloading release ${tag}..."
git clone --depth 1 --branch "$tag" "https://github.com/${repo_slug}.git" "$dest"

echo "Building and installing nudgelan-agent-bin..."
cd "$dest"
makepkg -si --noconfirm
echo "Installed: $(pacman -Q nudgelan-agent-bin)"
echo "NudgeLAN is installed. Pair from the iPhone."

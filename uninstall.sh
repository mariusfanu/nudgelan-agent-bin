#!/bin/bash
# Remove NudgeLAN from Omarchy. Run from a desktop terminal:
#   bash <(curl -fsSL https://github.com/mariusfanu/nudgelan-agent-bin/releases/latest/download/uninstall.sh)
set -euo pipefail

plugin_id=io.github.mariusfanu.nudgelan

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your desktop user. The script asks for your password when it needs root." >&2
  exit 1
fi

export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"

echo "Removing the NudgeLAN pill..."
omarchy plugin disable "$plugin_id" >/dev/null 2>&1 || true

config="$HOME/.config/omarchy/shell.json"
if [ -f "$config" ]; then
  python3 - "$config" "$plugin_id" <<'PY'
import json
import sys
path, plugin = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as handle:
    data = json.load(handle)

def drop(node):
    if isinstance(node, list):
        kept = []
        for item in node:
            if item == plugin or (isinstance(item, dict) and item.get("id") == plugin):
                continue
            kept.append(drop(item))
        return kept
    if isinstance(node, dict):
        return {key: drop(value) for key, value in node.items()}
    return node

with open(path, "w", encoding="utf-8") as handle:
    json.dump(drop(data), handle, indent=2)
    handle.write("\n")
PY
fi

rm -rf "$HOME/.config/omarchy/plugins/$plugin_id"
omarchy-shell shell reloadConfig >/dev/null 2>&1 || true

if [ -f "$config" ] && grep -q "$plugin_id" "$config"; then
  echo "The NudgeLAN pill is still listed in the bar configuration." >&2
  exit 1
fi

echo "Stopping the NudgeLAN agent..."
systemctl --user disable --now nudgelan-agent.service >/dev/null 2>&1 || true
if pgrep -x nudgelan-agent >/dev/null 2>&1; then
  pkill -x nudgelan-agent >/dev/null 2>&1 || true
  sleep 0.5
  pkill -9 -x nudgelan-agent >/dev/null 2>&1 || true
fi

echo "Removing NudgeLAN data..."
rm -rf \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nudgelan" \
  "${XDG_STATE_HOME:-$HOME/.local/state}/nudgelan" \
  "$HOME/.config/omarchy/nudgelan-listening.json"
if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  rm -rf "$XDG_RUNTIME_DIR/nudgelan"
fi

sudo -v
sudo systemctl --global disable nudgelan-agent.service >/dev/null 2>&1 || true
if [ -x /usr/bin/ufw ]; then
  nums=$(sudo ufw status numbered 2>/dev/null | sed -n 's/.*\[\s*\([0-9][0-9]*\)\].*# nudgelan.*/\1/p' | sort -nr || true)
  for n in $nums; do
    sudo ufw --force delete "$n" >/dev/null 2>&1 || true
  done
fi

if pacman -Q nudgelan-agent-bin >/dev/null 2>&1; then
  echo "Removing the package..."
  sudo pacman -R --noconfirm nudgelan-agent-bin
fi

rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/nudgelan-agent-bin"
echo "NudgeLAN has been removed."

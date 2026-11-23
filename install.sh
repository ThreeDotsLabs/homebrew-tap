#!/bin/sh
# Installs bento on Linux: the newest release for this computer's arch,
# its checksum checked, into ~/.local/bin (BENTO_BIN_DIR elsewhere). No
# sudo, nothing outside your home. On a Mac: brew install --cask
# threedotslabs/tap/bento.
#
#   curl -fsSL https://github.com/ThreeDotsLabs/homebrew-tap/raw/main/install.sh | sh
set -eu

repo=${BENTO_REPO:-ThreeDotsLabs/homebrew-tap}
dest=${BENTO_BIN_DIR:-$HOME/.local/bin}

if [ "$(uname -s)" != Linux ]; then
	echo "install.sh is for Linux. On a Mac: brew install --cask threedotslabs/tap/bento" >&2
	exit 1
fi
case $(uname -m) in
x86_64 | amd64) arch=amd64 ;;
aarch64 | arm64) arch=arm64 ;;
*)
	echo "bento is built for x86_64 and arm64, not $(uname -m)" >&2
	exit 1
	;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# BENTO_BASE serves the archives from elsewhere (a test: file:///dist).
base=${BENTO_BASE:-https://github.com/$repo/releases/latest/download}
echo "Downloading bento for Linux $arch…"
curl -fsSL "$base/bento-linux-$arch.tar.gz" -o "$tmp/bento-linux-$arch.tar.gz"
curl -fsSL "$base/bento-linux-checksums.txt" -o "$tmp/checksums.txt"
(cd "$tmp" && grep " bento-linux-$arch.tar.gz\$" checksums.txt | sha256sum -c - >/dev/null) || {
	echo "The download doesn't match its checksum: nothing was installed" >&2
	exit 1
}
tar -C "$tmp" -xzf "$tmp/bento-linux-$arch.tar.gz" bento
mkdir -p "$dest"
install -m 0755 "$tmp/bento" "$dest/bento"
echo "Installed $dest/bento"
case ":$PATH:" in
*":$dest:"*) ;;
*) echo "Add $dest to your PATH to run bento from a terminal." ;;
esac

# What bento uses that this computer doesn't have. Nothing is installed:
# each line says what the tool is for.
missing=""
need() {
	command -v "$1" >/dev/null 2>&1 || missing="$missing
  $1: $2"
}
need git "spaces and worktrees"
need claude "Claude Code, the agent bento runs (or codex)"
need bwrap "the Linux sandbox (bubblewrap)"
need docker "Docker sandboxes (or podman)"
need secret-tool "keeping accounts' tokens in your keyring (libsecret-tools)"
need notify-send "notifications (libnotify)"
if [ -n "${WAYLAND_DISPLAY:-}" ]; then
	need wl-paste "pasting images (wl-clipboard)"
else
	need xclip "pasting images"
fi
if [ -n "$missing" ]; then
	echo "Not on this computer yet; bento says where each one is needed:$missing"
fi
echo "Start it with: bento"

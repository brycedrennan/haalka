#!/usr/bin/env bash
set -euo pipefail

# Move to repository root (file is <repo>/.devcontainer/on_start.sh or similar)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Initialise / update submodules
git submodule update --init --recursive

# System packages (dev headers + just) – silent, minimal, non-interactive
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get -qq update
  sudo apt-get -y --no-install-recommends install \
       libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev just
fi

# Nickel CLI (static Linux binary, ~6 MB)
if ! command -v nickel >/dev/null 2>&1; then
  curl -sL \
    https://github.com/tweag/nickel/releases/latest/download/nickel-x86_64-unknown-linux-gnu.tar.gz \
  | sudo tar -xz -C /usr/local/bin --strip-components=1 nickel
fi

# WebAssembly target (unzips pre-built stdlib)
if ! rustup target list --installed | grep -q wasm32-unknown-unknown; then
  rustup target add wasm32-unknown-unknown
fi

# Prefetch crate graph (quiet)
cargo fetch --locked --all-targets --quiet

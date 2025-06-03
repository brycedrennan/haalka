#!/usr/bin/env bash
set -euo pipefail

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential git curl ca-certificates pkg-config libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev

git submodule update --init --recursive || true

if ! command -v nix >/dev/null 2>&1; then
  curl -L https://nixos.org/nix/install | bash -s -- --daemon
  . /etc/profile.d/nix.sh || true
fi

echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix profile install --accept-flake-config github:tweag/nickel || true
command -v nickel >/dev/null 2>&1 && nickel --version || true

if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
fi

rustup toolchain install stable
rustup toolchain install nightly
rustup component add clippy rustfmt --toolchain nightly

command -v just >/dev/null 2>&1 || cargo install just --locked
command -v cargo-binstall >/dev/null 2>&1 || cargo install cargo-binstall --locked
cargo binstall --no-confirm --continue-on-failure cargo-all-features || true
command -v cargo-cache >/dev/null 2>&1 || cargo install cargo-cache --locked

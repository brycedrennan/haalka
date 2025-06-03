#!/usr/bin/env bash
set -euo pipefail

### 1. System dependencies ####################################################
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
  build-essential git curl ca-certificates pkg-config \
  libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev

### 2. Rustup (pre-built toolchain) ###########################################
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
fi

rustup toolchain install stable
rustup toolchain install nightly
rustup component add clippy rustfmt --toolchain nightly

### 3. cargo-binstall bootstrap (pre-built binary) ###########################
if ! command -v cargo-binstall >/dev/null 2>&1; then
  curl -L --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
  | bash
fi

### 4. Git submodules (optional project checkout) ############################
git submodule update --init --recursive || true

### 5. Nix and Nickel (unchanged) ############################################
if ! command -v nix >/dev/null 2>&1; then
  curl -L https://nixos.org/nix/install | bash -s -- --daemon
  . /etc/profile.d/nix.sh || true
fi

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh || true
mkdir -p /etc/nix
grep -q '^experimental-features = nix-command flakes' /etc/nix/nix.conf 2>/dev/null || \
  echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf

nix profile install --accept-flake-config github:tweag/nickel || true
command -v nickel >/dev/null 2>&1 && nickel --version || true

### 6. Rust CLI utilities – binary-only installs ##############################
cargo binstall --no-confirm --no-fallback just cargo-all-features cargo-cache || true

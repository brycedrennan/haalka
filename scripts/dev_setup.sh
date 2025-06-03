#!/usr/bin/env bash
set -euo pipefail

# Determine repository root and move there
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# fetch git submodules
echo "Updating git submodules..."
git submodule update --init --recursive

echo "Installing system packages..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev
else
    echo "apt-get not found. Please install libasound2-dev libudev-dev libwayland-dev libxkbcommon-dev manually."
fi

echo "Checking required tools..."
if ! command -v just >/dev/null 2>&1; then
    echo "Installing just..."
    cargo install --locked just
else
    echo "just already installed"
fi

if ! command -v nickel >/dev/null 2>&1; then
    echo "Installing nickel-lang-cli..."
    cargo install --locked nickel-lang-cli
else
    echo "nickel already installed"
fi

# Add wasm target if necessary
if ! rustup target list --installed | grep -q wasm32-unknown-unknown; then
    echo "Adding wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi

# Prefetch project dependencies
echo "Fetching Cargo dependencies..."
cargo fetch --locked --all-targets

echo "Setup complete."

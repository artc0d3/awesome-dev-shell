#!/usr/bin/env bash
# End-to-end installation test for the Awesome Dev Shell on Ubuntu + Nix.
# 1. Downloads an Ubuntu WSL rootfs and imports it as a test WSL instance.
# 2. Creates the `dev` user, installs Nix, and applies the flake via Home Manager.
# 3. Verifies that key tools (fd, vfox, op, podman) are available and zsh works.
# 4. Removes the test instance on success (unless --keep is specified).
#
# Usage:
# Run the script from the repository root *inside* a WSL instance.
#   ./wsl-e2e-test.sh [branch-name] [--keep]
#     * branch-name - optional name of the Git branch to test. If not provided, the current branch will be used.
#     * --keep - optional flag to keep the test WSL instance after the test

set -euo pipefail

# --- Colors ---
CYAN='\033[38;2;150;200;230m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DARK_CYAN='\033[38;2;100;170;200m'
RESET='\033[0m'

step() { echo -e "${CYAN}  ● $1${RESET}"; }
success() { echo -e "${GREEN}  ● $1${RESET}"; }
fail() {
  echo -e "${RED}$1${RESET}"
  exit 1
}

# Run wsl from a Windows-native directory to avoid path translation warnings
wsl() { (cd /mnt/c && wsl.exe "$@"); }

# --- Parse arguments ---
BRANCH=""
KEEP=false

for arg in "$@"; do
  if [[ "$arg" == "--keep" ]]; then
    KEEP=true
  elif [[ -z "$BRANCH" ]]; then
    BRANCH="$arg"
  fi
done

# --- Configuration ---
DISTRO="ads-test"
# Canonical's WSL image for Ubuntu 24.04 (Noble). `.wsl` files are gzipped
# tarballs that `wsl --import` accepts. Update the series if the project's
# target Ubuntu changes.
DOWNLOAD_URL="https://cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl"
USERNAME="dev"

# Use a directory on the Windows filesystem (wsl --import requires it)
WIN_USERPROFILE=$(wslpath "$(cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
TEST_DIR="$WIN_USERPROFILE/.ads-test"
WSL_FILE="$TEST_DIR/ubuntu.wsl"
INSTANCE_DIR="$TEST_DIR/$DISTRO"

# Clean up any leftover test instance from a previous run
wsl --unregister "$DISTRO" >/dev/null 2>&1 || true

# Resolve branch name
if [[ -z "$BRANCH" ]]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    echo -e "${DARK_CYAN}  Using current branch: $BRANCH${RESET}"
  else
    fail "Error: No branch specified and not in a Git-managed directory."
  fi
fi

FLAKE_REF="github:artc0d3/awesome-dev-shell?ref=$BRANCH#wsl"

# Ensure .test directory exists
mkdir -p "$TEST_DIR"

# Download Ubuntu WSL rootfs
if [[ -f "$WSL_FILE" ]]; then
  step "Existing Ubuntu rootfs found in $WSL_FILE. Will use it for the test."
else
  step "Downloading Ubuntu WSL rootfs..."
  curl -L -o "$WSL_FILE" "$DOWNLOAD_URL"
fi

# Convert Linux paths to Windows paths for wsl --import
WIN_INSTANCE_DIR=$(wslpath -w "$INSTANCE_DIR")
WIN_WSL_FILE=$(wslpath -w "$WSL_FILE")

step "Creating test Ubuntu instance..."
wsl --import "$DISTRO" "$WIN_INSTANCE_DIR" "$WIN_WSL_FILE" --version 2 || fail "Failed to import WSL distribution."

step "Provisioning user '$USERNAME' and enabling systemd..."
wsl -d "$DISTRO" -u root -- bash -c "
  set -e
  if ! id -u $USERNAME >/dev/null 2>&1; then
    useradd -m -s /bin/bash $USERNAME
  fi
  echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME
  chmod 0440 /etc/sudoers.d/$USERNAME
  printf '[user]\ndefault=$USERNAME\n[boot]\nsystemd=true\n' > /etc/wsl.conf
" || fail "Failed to provision user."

step "Restarting instance to apply default-user and systemd..."
wsl -t "$DISTRO"

step "Installing Nix (Determinate Systems installer)..."
wsl -d "$DISTRO" -u root -- bash -c "
  set -e
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates xz-utils
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --init systemd --no-confirm
" || fail "Failed to install Nix."

step "Restarting instance to pick up Nix profile..."
wsl -t "$DISTRO"

step "Applying Home Manager configuration..."
# `-b backup` lets Home Manager move pre-existing dotfiles aside instead of aborting.
# `--refresh` forces a re-fetch of the flake, useful when testing force-pushed branches.
wsl -d "$DISTRO" -- bash -lc "
  nix run github:nix-community/home-manager/release-26.05 -- \
    switch --flake '$FLAKE_REF' -b backup --refresh
" || fail "Failed to apply Home Manager configuration."

step "Restarting instance for clean environment..."
wsl -t "$DISTRO"

# --- Smoke tests ---

step "Running smoke tests..."

run_in_distro() {
  wsl -d "$DISTRO" -- bash -lc "$1" 2>&1 | tr -d '\r'
}

# Test: fd
fd_output=$(run_in_distro 'fd -V')
if ! echo "$fd_output" | grep -q "^fd"; then
  fail "Smoke test for \"fd\" failed.\nExpected a line starting with: fd\nActual output:\n$fd_output"
else
  success "Smoke test for \"fd\" passed."
fi

# Test: vfox
vfox_output=$(run_in_distro 'vfox --version')
if ! echo "$vfox_output" | grep -q "^vfox version"; then
  fail "Smoke test for \"vfox\" failed.\nExpected a line starting with: vfox version\nActual output:\n$vfox_output"
else
  success "Smoke test for \"vfox\" passed."
fi

# Test: zsh — Home Manager can't chsh the user's login shell on Ubuntu, so we
# verify the binary is installed and runnable instead of checking $0.
zsh_output=$(run_in_distro 'zsh --version')
if ! echo "$zsh_output" | grep -q "^zsh"; then
  fail "Smoke test for ZSH failed.\nExpected a line starting with: zsh\nActual output:\n$zsh_output"
else
  success "Smoke test for ZSH passed."
fi

# Test: op cli
op_cli_output=$(run_in_distro 'op --version')
echo "\"$op_cli_output\""
if ! echo "$op_cli_output" | grep -Eq "^[0-9.]+$"; then
  fail "Smoke test for \"op cli\" failed.\nExpected a line with: version number\nActual output:\n$op_cli_output"
else
  success "Smoke test for \"op cli\" passed."
fi

# Test: podman
podman_output=$(run_in_distro 'podman --version')
echo "\"$podman_output\""
if ! echo "$podman_output" | grep -Eq "^podman version [0-9.]+$"; then
  fail "Smoke test for \"podman\" failed.\nExpected a line with: podman version x.y.z\nActual output:\n$podman_output"
else
  success "Smoke test for \"podman\" passed."
fi

success "Smoke test succeeded!"

# Cleanup
if [[ "$KEEP" == true ]]; then
  step "Keeping test instance '$DISTRO'. Remove it manually with: wsl --unregister $DISTRO"
else
  step "Removing test instance '$DISTRO'..."
  wsl --unregister "$DISTRO"
fi

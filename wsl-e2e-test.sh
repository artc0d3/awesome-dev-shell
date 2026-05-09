#!/usr/bin/env bash
# End-to-end installation test for the Awesome Dev Shell NixOS configuration.
# 1. Downloads a NixOS-WSL distribution and imports it as a test WSL instance.
# 2. Applies the flake from the specified (or current) Git branch.
# 3. Verifies that key tools (fd, vfox) are available and zsh is the default shell.
# 4. Removes the test instance on success (unless --keep is specified).
#
# Usage:
# Run the script from the repository root *inside* a WSL instance.
#   ./test/smoke-test.sh [branch-name] [--keep]
#     * branch-name - optional name of the Git branch to test. If not provided, the current branch will be used.
#     * --keep - optional flag to keep the test WSL instance after the test

set -euo pipefail

# --- Colors ---
CYAN='\033[38;2;150;200;230m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DARK_CYAN='\033[38;2;100;170;200m'
RESET='\033[0m'

step()    { echo -e "${CYAN}  ● $1${RESET}"; }
success() { echo -e "${GREEN}  ● $1${RESET}"; }
fail()    { echo -e "${RED}$1${RESET}"; exit 1; }

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
DISTRO="nixos-test"
DOWNLOAD_URL="https://github.com/nix-community/NixOS-WSL/releases/download/2511.7.1/nixos.wsl"

# Use a directory on the Windows filesystem (wsl --import requires it)
WIN_USERPROFILE=$(wslpath "$(cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
TEST_DIR="$WIN_USERPROFILE/.ads-test"
WSL_FILE="$TEST_DIR/nixos.wsl"
INSTANCE_DIR="$TEST_DIR/nixos-test"

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

# Download NixOS-WSL distribution
if [[ -f "$WSL_FILE" ]]; then
    step "Existing NixOS distribution found in $WSL_FILE. Will use it for the test."
else
    step "Downloading NixOS distribution..."
    curl -L -o "$WSL_FILE" "$DOWNLOAD_URL"
fi

# Convert Linux paths to Windows paths for wsl --import
WIN_INSTANCE_DIR=$(wslpath -w "$INSTANCE_DIR")
WIN_WSL_FILE=$(wslpath -w "$WSL_FILE")

# Create test NixOS instance
step "Creating test NixOS instance..."
wsl --import "$DISTRO" "$WIN_INSTANCE_DIR" "$WIN_WSL_FILE" --version 2 || fail "Failed to import WSL distribution."

# Update NixOS
step "Updating NixOS..."
wsl -d "$DISTRO" -- sudo nix-channel --update || fail "Failed to update nix channels."

step "Rebuilding NixOS (base)..."
wsl -d "$DISTRO" -- sudo nixos-rebuild switch || fail "Failed to rebuild NixOS."

step "Terminating instance for clean restart..."
wsl -t "$DISTRO"

step "Installing Awesome Dev Shell..."
wsl -d "$DISTRO" -- sudo nixos-rebuild switch --flake "$FLAKE_REF" --refresh || fail "Failed to install Awesome Dev Shell."

step "Terminating instance for clean restart..."
wsl -t "$DISTRO"

# --- Smoke tests ---

step "Running smoke tests..."

# Test: fd
fd_output=$(wsl -d "$DISTRO" -- fd -V 2>&1 | tr -d '\r')
if ! echo "$fd_output" | grep -q "^fd"; then
    fail "Smoke test for \"fd\" failed.\nExpected a line starting with: fd\nActual output:\n$fd_output"
fi

# Test: vfox
vfox_output=$(wsl -d "$DISTRO" -- vfox --version 2>&1 | tr -d '\r')
if ! echo "$vfox_output" | grep -q "^vfox version"; then
    fail "Smoke test for \"vfox\" failed.\nExpected a line starting with: vfox version\nActual output:\n$vfox_output"
fi

# Test: zsh
zsh_output=$(wsl -d "$DISTRO" -- echo '$0' 2>&1 | tr -d '\r')
if ! echo "$zsh_output" | grep -q "^zsh$"; then
    fail "Smoke test for ZSH failed.\nExpected a line with: zsh\nActual output:\n$zsh_output"
fi

success "Smoke test succeeded!"

# Cleanup
if [[ "$KEEP" == true ]]; then
    step "Keeping test instance '$DISTRO'. Remove it manually with: wsl --unregister $DISTRO"
else
    step "Removing test instance '$DISTRO'..."
    wsl --unregister "$DISTRO"
fi

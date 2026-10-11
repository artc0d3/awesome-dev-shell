#!/bin/bash
# Refresh all flake inputs (nixpkgs, nixpkgs-unstable, home-manager) in flake.lock.
#
# Fast-moving packages such as claude-code and tuicr are pulled from
# nixpkgs-unstable, so run this to pick up newer versions, then re-apply with
# ./apply-mac.sh or ./apply-wsl.sh. The lock file is shared across platforms, so
# this script is platform-agnostic.
#
# To update a single input only: nix flake update nixpkgs-unstable

nix flake update

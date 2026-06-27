#!/bin/bash
# Dry-build the Home Manager configuration without activating it.
nix build --no-link '.#homeConfigurations.wsl.activationPackage'
#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_NIX="$SCRIPT_DIR/user.nix"

read -p "OS username: " username
read -p "Git name (global): " gitname
read -p "Git email (global): " gitemail

cat > "$USER_NIX" << EOF
{
  username = "$username";
  gitName = "$gitname";
  gitEmail = "$gitemail";
}
EOF

echo "Created $USER_NIX with custom user settings."
echo "Rebuilding NixOS configuration with the new user settings..."
sudo nixos-rebuild switch --flake "$SCRIPT_DIR#wsl"

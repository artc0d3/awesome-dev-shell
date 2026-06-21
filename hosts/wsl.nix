# WSL-specific configuration.
# Everything in this file is specific to running NixOS under Windows Subsystem for Linux.
{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  # Bubblewrap is required for sandboxing in WSL. Used by Claude Code.
  sandbox = {
    home-manager.users.${username}.home.packages = with pkgs; [
      bubblewrap
    ];
  };
  wsl = {
    wsl.enable = true;
    wsl.defaultUser = username;
  };
in
{
  imports = [
    ../modules/ld.nix
    ../modules/podman.nix
  ];

  config = lib.mkMerge [
    sandbox
    wsl
    {
      programs.nix-ld-libs.enable = true;
      programs.podman-containers.enable = true;
    }
    {
      system.activationScripts.postRebuildHint.text = ''
        echo ""
        echo "################################################################################"
        echo "# System has been rebuilt. To make everything smooth, I recommend to restart the WSL instance:"
        echo "#   exit"
        echo "#   wsl --shutdown"
        echo "#   wsl -d nixos"
        echo "################################################################################"
        echo ""
      '';
    }
  ];
}

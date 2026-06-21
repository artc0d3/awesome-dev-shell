# WSL-specific configuration.
# Everything in this file is specific to running NixOS under Windows Subsystem for Linux.
{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ../modules/ld.nix
    ../modules/podman.nix
  ];

  config = lib.mkMerge [
    {
      wsl.enable = true;
      wsl.defaultUser = username;
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

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
  # Nix-ld is required for tools that download and execute binaries, such as vfox.
  # NixOS doesn't provide a standard dynamic linker at /lib64/ld-linux-x86-64.so.2,
  # so externally downloaded ELF binaries can't run without it.
  # The listed libraries are required for Node.js and JDK.
  nix-ld = {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      alsa-lib
      fontconfig
      freetype
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      zlib
    ];
  };
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
    ../modules/podman.nix
  ];

  config = lib.mkMerge [
    nix-ld
    sandbox
    wsl
    {
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

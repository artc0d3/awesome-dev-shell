# WSL-specific configuration.
# Everything in this file is specific to running NixOS under Windows Subsystem for Linux.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  git = {
    # Use the Windows SSH binary for 1Password SSH agent forwarding.
    home-manager.users.dev.programs.git.settings.core.sshCommand = "ssh.exe";
  };
  # Nix-ld is required for tools that download and execute binaries, such as vfox.
  # NixOS doesn't provide a standard dynamic linker at /lib64/ld-linux-x86-64.so.2,
  # so externally downloaded ELF binaries can't run without it.
  nix-ld = {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      icu
    ];
  };
  podman = {
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    home-manager.users.dev.home.packages = with pkgs; [
      podman-compose
    ];
  };
  # Bubblewrap is required for sandboxing in WSL. Used by Claude Code.
  sandbox = {
    home-manager.users.dev.home.packages = with pkgs; [
      bubblewrap
    ];
  };
  wsl = {
    wsl.enable = true;
    wsl.defaultUser = "dev";
  };
in
lib.mkMerge [
  git
  nix-ld
  podman
  sandbox
  wsl
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
]

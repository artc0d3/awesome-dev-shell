# WSL-specific configuration.
# Everything in this file is specific to running NixOS under Windows Subsystem for Linux.
{ config, pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "dev";

  home-manager.users.dev.home.packages = with pkgs; [
    bubblewrap
    podman-compose
  ];

  # Use the Windows SSH binary for 1Password SSH agent forwarding.
  home-manager.users.dev.programs.git.settings.core.sshCommand = "ssh.exe";

  services.dbus.implementation = "dbus";

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Nix-ld is required for tools that download and execute binaries, such as vfox.
  # NixOS doesn't provide a standard dynamic linker at /lib64/ld-linux-x86-64.so.2,
  # so externally downloaded ELF binaries can't run without it.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
  ];

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

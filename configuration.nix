{ config, pkgs, lib, ... }: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "claude-code"
    ];

  wsl.enable = true;
  wsl.defaultUser = "dev";

  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;

  # Nix-ld is required for tools that download and execute binaries, such as vfox.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
  ];

  services.dbus.implementation = "dbus";

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.dev = import ./home.nix;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  system.stateVersion = "25.11";
}

{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./modules/ld.nix
    ./modules/podman.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;
  ads.nix-ld-libs.enable = true;
  ads.podman-containers.enable = true;

  wsl.enable = true;
  wsl.defaultUser = username;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit username; };
    users.${username} = import ./home.nix;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";

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

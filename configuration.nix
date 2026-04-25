{ config, pkgs, ... }:
let
  user = import ./user.nix;
in {
  wsl.enable = true;
  wsl.defaultUser = user.username;

  users.users.${user.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
  ];

  programs.zsh.enable = true;

  services.dbus.implementation = "dbus";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user.username} = import ./home.nix user;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.activationScripts.postRebuildHint.text = ''
    echo ""
    echo "#######"
    echo "# To customize your environment, clone the repo and run customize.sh:"
    echo "#   git clone https://github.com/artc0d3/awesome-dev-shell ~/.nix-config"
    echo "#   cd ~/.nix-config && ./customize.sh"
    echo "#"
    echo "# To rebuild manually after customizing:"
    echo "#   sudo nixos-rebuild switch --flake ~/.nix-config#wsl"
    echo "#######"
    echo ""
  '';

  system.stateVersion = "25.11";
}

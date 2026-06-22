{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  ads = import ./ads { inherit pkgs; };
in
{
  imports = [
    ./modules/claude.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/op-wsl.nix
    ./modules/podman.nix
    ./modules/shell.nix
    ./modules/shell-tools.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  home.packages = [
    ads
    pkgs.nixfmt
    pkgs.podman
    pkgs.podman-compose
  ];

  ads.claude.enable = true;
  ads.dev-tools.enable = true;
  ads.neovim-lazyvim.enable = true;
  ads.op-wsl.enable = true;
  ads.podman.enable = true;
  ads.op-wsl.sshAgent.enable = true;
  ads.shell.enable = true;
  ads.shell-tools.enable = true;
}

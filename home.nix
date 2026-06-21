{
  config,
  pkgs,
  lib,
  ...
}:
let
  ads = import ./ads { inherit pkgs; };
in
{
  imports = [
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/op-wsl.nix
    ./modules/shell.nix
    ./modules/shell-tools.nix
  ];

  home.stateVersion = "25.11";

  home.packages = [
    ads
    pkgs.nixfmt
  ];

  ads.dev-tools.enable = true;
  ads.neovim-lazyvim.enable = true;
  ads.op-wsl.enable = true;
  ads.op-wsl.sshAgent.enable = true;
  ads.shell.enable = true;
  ads.shell-tools.enable = true;
}

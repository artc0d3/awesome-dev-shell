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
  ]
  ++ (with pkgs; [
    claude-code
    nixfmt
  ]);

  programs.dev-tools.enable = true;
  programs.neovim-lazyvim.enable = true;
  programs.op-wsl.enable = true;
  programs.op-wsl.sshAgent.enable = true;
  programs.shell.enable = true;
  programs.shell-tools.enable = true;
}

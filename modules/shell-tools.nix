# General-purpose CLI productivity tools.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.shell-tools;
in
{
  options.ads.shell-tools = {
    enable = lib.mkEnableOption "general-purpose CLI productivity tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      jq
      ripgrep
      sd
      unzip
    ];

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.bat.enable = true;

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
    };
  };
}

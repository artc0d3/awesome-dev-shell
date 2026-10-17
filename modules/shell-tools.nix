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
    };

    programs.bat.enable = true;

    # Syntax-highlighted diffs for git (git diff/log/show/add -p) and lazygit
    # (see git.pagers in configs/lazygit/config.yml). enableGitIntegration sets
    # delta as git's pager and interactive diff filter.
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        # n/N jump between files in a diff.
        navigate = true;
        line-numbers = true;
      };
    };

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

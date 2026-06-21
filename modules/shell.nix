# Shell configuration: Zsh + Starship prompt.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.shell;
in
{
  options.ads.shell = {
    enable = lib.mkEnableOption "Zsh + Starship shell configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
      };
      initContent = ''
        [ -f ~/.zshrc.local ] && source ~/.zshrc.local
        eval "$(vfox activate zsh)"
      '';
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ../configs/starship/config.toml);
    };
  };
}

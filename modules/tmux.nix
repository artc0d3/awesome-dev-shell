# tmux terminal multiplexer with custom keybindings and Neovim-aware pane navigation.
{
  config,
  lib,
  ...
}:
let
  cfg = config.ads.tmux;
in
{
  options.ads.tmux = {
    enable = lib.mkEnableOption "tmux terminal multiplexer with custom configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ../configs/tmux/tmux.conf;
    };
  };
}

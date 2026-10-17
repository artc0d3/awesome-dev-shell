# tmux terminal multiplexer with custom keybindings and Neovim-aware pane navigation.
#
# ~/.config/tmux/tmux.conf is an out-of-store symlink to configs/tmux/tmux.conf
# in this repo's working tree (see modules/dotfiles.nix), so it can be edited
# live and committed without a Home Manager redeploy. Reload a running server
# with `tmux source-file ~/.config/tmux/tmux.conf`.
#
# programs.tmux is deliberately not used: it renders tmux.conf itself (its own
# defaults followed by extraConfig) into the immutable Nix store, which would
# defeat the live-editing above. Everything tmux needs is therefore set in the
# linked tmux.conf; tmux (>= 3.1) reads ~/.config/tmux/tmux.conf on every
# platform without any extra setup.
{
  config,
  pkgs,
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
    home.packages = [ pkgs.tmux ];

    xdg.configFile."tmux/tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.ads.dotfilesRoot}/configs/tmux/tmux.conf";
  };
}

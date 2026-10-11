# Neovim with a LazyVim-based configuration.
#
# ~/.config/nvim is an out-of-store symlink to configs/nvim in this repo's
# working tree (see modules/dotfiles.nix). Editing the live config therefore
# edits the tracked files directly: changes take effect immediately in Neovim,
# are committed straight to git, and can be restored with `git checkout` — no
# Home Manager redeploy required. LazyVim writes lazy-lock.json back into this
# directory, which lands in the working tree and should be committed.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.neovim-lazyvim;
in
{
  options.ads.neovim-lazyvim = {
    enable = lib.mkEnableOption "Custom Neovim configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      lazygit

      # Treesitter and tools to compile the parsers on the fly.
      tree-sitter
      gcc
      gnumake

      # Snacks dependencies.
      fd
      ripgrep

      # Unzip is required by Mason to install the LSP tooling
      unzip
    ];

    # Link ~/.config/nvim to the config tracked in this repo. See the module
    # header for the rationale. Note: if ~/.config/nvim already exists as a real
    # directory (e.g. from the previous clone-based setup), Home Manager will
    # refuse to replace it — move or remove it first, after saving any unpushed
    # edits.
    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.ads.dotfilesRoot}/configs/nvim";
  };
}

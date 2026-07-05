# Neovim with LazyVim starter configuration.
# Installs Neovim and bootstraps the LazyVim starter template on first
# activation.  The resulting ~/.config/nvim is a plain, mutable directory
# that the user can freely edit — Nix will not overwrite it on subsequent
# rebuilds.
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
    enable = lib.mkEnableOption "Neovim with LazyVim starter configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      lazygit

      # Treesitter parsers are compiled on the fly; they need a C compiler and make.
      gcc
      gnumake

      # Telescope dependencies.
      fd
      ripgrep

      # Unzip is required by Mason to install the LSP tooling
      unzip
    ];

    # Managed plugin: symlinked from the Nix store so it stays in sync with the repo.
    # The lua/plugins/ directory is a regular mutable directory — users can freely add
    # other plugin files alongside this one.
    home.file.".config/nvim/lua/plugins/smart-splits.lua" = {
      source = ../configs/nvim/plugins/smart-splits.lua;
    };

    # Clone the LazyVim starter into ~/.config/nvim the first time home-manager activates.
    # Checks for init.lua rather than the directory itself, because home.file may have
    # pre-created ~/.config/nvim/lua/plugins/ before this activation runs.
    # Uses a temp dir so the clone doesn't fail on a non-empty target directory.
    # Subsequent activations are a no-op so user modifications are preserved.
    home.activation.bootstrapLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      nvim_config="${config.home.homeDirectory}/.config/nvim"
      if [ ! -f "$nvim_config/init.lua" ]; then
        tmp=$(${pkgs.coreutils}/bin/mktemp -d)
        run ${pkgs.git}/bin/git clone https://github.com/LazyVim/starter "$tmp/starter"
        run ${pkgs.coreutils}/bin/rm -rf "$tmp/starter/.git"
        run ${pkgs.coreutils}/bin/cp -rn "$tmp/starter/." "$nvim_config/"
        run ${pkgs.coreutils}/bin/rm -rf "$tmp"
      fi
    '';
  };
}

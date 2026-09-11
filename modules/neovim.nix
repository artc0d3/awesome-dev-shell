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

    # Seed the Neovim config if none present yet
    home.activation.bootstrapLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      nvim_config="${config.home.homeDirectory}/.config/nvim"
      if [ ! -f "$nvim_config/init.lua" ]; then
        tmp=$(${pkgs.coreutils}/bin/mktemp -d)
        run ${pkgs.git}/bin/git clone https://github.com/artc0d3/neovim.git "$tmp/starter"
        run ${pkgs.coreutils}/bin/cp -rn "$tmp/starter/." "$nvim_config/"
        run ${pkgs.coreutils}/bin/rm -rf "$tmp"
      fi
    '';
  };
}

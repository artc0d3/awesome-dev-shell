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

    # Clone the LazyVim starter into ~/.config/nvim the first time
    # home-manager activates.  Subsequent activations are a no-op so
    # user modifications are preserved.
    home.activation.bootstrapLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${config.home.homeDirectory}/.config/nvim" ]; then
        run ${pkgs.git}/bin/git clone https://github.com/LazyVim/starter "${config.home.homeDirectory}/.config/nvim"
        run ${pkgs.coreutils}/bin/rm -rf "${config.home.homeDirectory}/.config/nvim/.git"
      fi
    '';
  };
}

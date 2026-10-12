# Developer workflow tools: version control, version management, and utilities.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.dev-tools;
  lazygitConfig = config.lib.file.mkOutOfStoreSymlink "${config.ads.dotfilesRoot}/configs/lazygit/config.yml";
in
{
  options.ads.dev-tools = {
    enable = lib.mkEnableOption "Developer workflow tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cloc
      dos2unix
      gh
      mise
      nixfmt
      posting
      # Pulled from nixpkgs-unstable (see the overlay in flake.nix): tuicr is only
      # packaged on the fast-moving channel. Bump with `nix flake update nixpkgs-unstable`.
      unstable.tuicr
      uv
    ];

    # Set up a global Node.js toolchain via mise.
    #
    # This is imperative rather than declarative because mise manages its own tool installs
    # outside the Nix store; running it here just seeds the initial state on a fresh machine.
    home.activation.setupNodeToolchain = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.mise}/bin:$PATH"
      run mise use --global nodejs@26
    '';

    # Linked out-of-store (to the repo working tree) so it can be edited live and
    # committed without a redeploy. See modules/dotfiles.nix.
    xdg.configFile."tuicr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.ads.dotfilesRoot}/configs/tuicr/config.toml";

    # Lazygit config, linked out-of-store like tuicr's above. (The lazygit package
    # itself comes with neovim.nix, which uses it for Snacks.lazygit.)
    #
    # Only the file is linked, not the directory: lazygit writes its own state.yml
    # next to it, which does not belong in the repo.
    #
    # On macOS, lazygit reads ~/Library/Application Support/lazygit, not
    # ~/.config/lazygit, unless XDG_CONFIG_HOME is set (which this setup doesn't).
    # Linking to the native location avoids exporting XDG_CONFIG_HOME, which would
    # move the config of every other XDG-aware tool on the Mac as well.
    home.file."Library/Application Support/lazygit/config.yml" = lib.mkIf pkgs.stdenv.isDarwin {
      source = lazygitConfig;
    };
    xdg.configFile."lazygit/config.yml" = lib.mkIf (!pkgs.stdenv.isDarwin) {
      source = lazygitConfig;
    };

    # Seed an empty, user-editable ~/.gitconfig on install if one does not exist.
    #
    # Home Manager renders ~/.config/git/config as an immutable Nix-store symlink.
    # If ~/.gitconfig doesn't exist, `git config` commands try to modify ~/.config/git/config which
    # fails, because of immutability. Creating .gitconfig allows user to provide their local config.
    home.activation.seedGitConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${config.home.homeDirectory}/.gitconfig" ]; then
        run touch "${config.home.homeDirectory}/.gitconfig"
      fi
    '';

    programs.git = {
      enable = true;
      signing = {
        # SSH-based commit signing; the private key is served by the ssh-agent
        # (see modules/ssh.nix). Expects the private signing key at ~/.ssh/signing-key
        # (public half ~/.ssh/signing-key.pub).
        format = "ssh";
        key = "~/.ssh/signing-key.pub";
        signByDefault = true;
      };
      settings = {
        # The file itself is not managed here — populate ~/.config/git/allowed_signers manually with `<email> <contents of
        # signing-key.pub>` to enable local verification. Until then, verification reports "no signature could be checked", but signing itself is unaffected.
        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      };
    };
  };
}

# Developer workflow tools: version control, version management, and utilities.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.dev-tools;
in
{
  options.ads.dev-tools = {
    enable = lib.mkEnableOption "Developer workflow tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cloc
      mise
      uv
    ];

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

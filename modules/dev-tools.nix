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
      extraConfig = {
        # The file itself is not managed here — populate ~/.config/git/allowed_signers manually with `<email> <contents of
        # signing-key.pub>` to enable local verification. Until then, verification reports "no signature could be checked", but signing itself is unaffected.
        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      };
    };
  };
}

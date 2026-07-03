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
        # (see modules/ssh.nix). The signing key is expected at ~/.ssh/signing-key.
        format = "ssh";
        key = "~/.ssh/signing-key.pub";
        signByDefault = true;
      };
    };
  };
}

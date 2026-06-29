# Claude Code CLI.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.claude;
in
{
  options.ads.claude = {
    enable = lib.mkEnableOption "Claude Code CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
    ];
  };
}

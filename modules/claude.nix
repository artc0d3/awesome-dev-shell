# Claude Code CLI.
{
  config,
  pkgs,
  lib,
  username,
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
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];

    home-manager.users.${username}.home.packages = with pkgs; [
      claude-code
    ];
  };
}

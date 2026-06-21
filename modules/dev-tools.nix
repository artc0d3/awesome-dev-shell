# Developer workflow tools: version control, version management, and utilities.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.dev-tools;
in
{
  options.programs.dev-tools = {
    enable = lib.mkEnableOption "developer workflow tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cloc
      uv
      vfox
    ];

    programs.git = {
      enable = true;
      signing.format = null;
    };
  };
}

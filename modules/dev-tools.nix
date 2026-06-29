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
      devcontainer
      mise
      uv
    ];

    # Make sure that devcontainers use podman
    home.sessionVariables.DEVCONTAINER_DOCKER_PATH = "podman";

    programs.git = {
      enable = true;
      signing.format = null;
    };
  };
}

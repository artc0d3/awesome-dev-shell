# macOS container engine via Colima (open-source, Nix-manageable, Docker-compatible).
#
# After the first `home-manager switch`, run `colima start` once manually — launchd only
# registers the agent for the *next* login, so the initial start must be done by hand.
# On all subsequent logins, launchd auto-starts Colima before the first terminal opens.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.colima;
in
{
  options.ads.colima = {
    enable = lib.mkEnableOption "Colima container engine for macOS";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.colima
      pkgs.docker-client
    ];

    # Point the docker CLI at Colima's socket instead of Docker Desktop's.
    home.sessionVariables.DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";

    launchd.agents.colima = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.colima}/bin/colima"
          "start"
        ];
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/.colima/launchd.log";
        StandardErrorPath = "${config.home.homeDirectory}/.colima/launchd.log";
      };
    };
  };
}

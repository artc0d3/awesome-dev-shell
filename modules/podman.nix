# Podman container runtime with Docker compatibility.
{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  cfg = config.programs.podman-containers;
in
{
  options.programs.podman-containers = {
    enable = lib.mkEnableOption "Podman container runtime with Docker compatibility";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    home-manager.users.${username}.home.packages = with pkgs; [
      podman-compose
    ];
  };
}

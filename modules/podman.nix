# Rootless Podman configuration for non-NixOS systems.
# Provides the containers policy required by Podman and basic registries config.
# Users must manually install the packages uidmap and slirp4netns, and and subuids and subgids for the user:
# sudo apt install -y uidmap slirp4netns
# sudo usermod --add-subuids 200000-201000 -add-subgids 200000-201000 <username>
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.podman;
in
{
  options.ads.podman = {
    enable = lib.mkEnableOption "Rootless Podman configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.podman
      pkgs.podman-compose
      (pkgs.runCommand "podman-docker-symlink" { } ''
        mkdir -p $out/bin
        ln -s ${pkgs.podman}/bin/podman $out/bin/docker
      '')
    ];

    xdg.configFile."containers/policy.json".text = builtins.toJSON {
      default = [ { type = "insecureAcceptAnything"; } ];
    };
  };
}

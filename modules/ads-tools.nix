# ADS CLI and Nix formatting tools.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  ads = import ../ads { inherit pkgs; };
  cfg = config.ads.ads-tools;
in
{
  options.ads.ads-tools = {
    enable = lib.mkEnableOption "ADS CLI and Nix formatting tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      ads
      pkgs.nixfmt
    ];
  };
}

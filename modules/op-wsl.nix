# 1Password integration for WSL.
# Installs the wslop CLI client so native Linux tools can pull secrets from the
# Windows 1Password vault (e.g. `op inject`). SSH authentication is handled by a
# Linux-native SSH agent, not 1Password.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.op-wsl;
in
{
  options.ads.op-wsl = {
    enable = lib.mkEnableOption "1Password CLI (wslop) integration";
  };

  config = lib.mkIf cfg.enable {
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.activation.installWslop = lib.hm.dag.entryAfter [ "installPackages" ] ''
      export PATH="${config.home.homeDirectory}/.local/bin:$PATH"
      run ${pkgs.uv}/bin/uv tool install wslop
    '';
  };
}

# AI coding agents: Claude Code and Pi.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.ai;
  npmPrefix = "${config.home.homeDirectory}/.npm-global";
in
{
  options.ads.ai = {
    enable = lib.mkEnableOption "Coding agents";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code
      nodejs_24
      nono
    ];

    # Redirect global npm installs to a user-writable prefix so packages like
    # the Pi coding agent can be installed without touching the Nix store.
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmPrefix;
    };

    home.sessionPath = [ "${npmPrefix}/bin" ];

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.nodejs_24}/bin:$PATH"
      export NPM_CONFIG_PREFIX="${npmPrefix}"
      run npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    '';
  };
}

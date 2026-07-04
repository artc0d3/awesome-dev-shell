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

    # Nono sandbox profiles for coding agents
    xdg.configFile."nono/profiles/yolo-claude.json".source = ../configs/nono/yolo-claude.json;
    xdg.configFile."nono/profiles/yolo-pi.json".source = ../configs/nono/yolo-pi.json;

    # Aliases for launching agents in yolo mode.
    # TMPDIR is set on the parent env rather than in the profile: nono inherits
    # all env vars by default.
    programs.zsh.shellAliases.yoloclaude =
      "TMPDIR=/tmp/claude-1000 nono run --profile yolo-claude -- claude --dangerously-skip-permissions";
    programs.zsh.shellAliases.yolopi =
      "TMPDIR=/tmp/pi nono run --profile yolo-pi -- pi";

    home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.nodejs_24}/bin:$PATH"
      export NPM_CONFIG_PREFIX="${npmPrefix}"
      run npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    '';
  };
}

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

    piPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "npm:pi-subagents"
        "git:github.com/user/repo@v1"
      ];
      description = ''
        Pi coding agent packages to install declaratively. Each entry is a Pi
        package source string as accepted by `pi install`
        (e.g. "npm:pi-subagents", "git:github.com/user/repo@v1", or an absolute
        path). They are installed during Home Manager activation via
        `pi install`, which is idempotent and records them in
        ~/.pi/agent/settings.json.

        Note: removing an entry here does NOT uninstall the package — run
        `pi remove <source>` for that.
      '';
    };
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

    # Install declared Pi packages
    home.activation.installPiPackages = lib.mkIf (cfg.piPackages != [ ]) (
      lib.hm.dag.entryAfter [ "installPiCodingAgent" ] ''
        # git is needed for `git:` package sources; the activation PATH is
        # minimal, so add it explicitly rather than relying on the login shell.
        export PATH="${pkgs.nodejs_24}/bin:${npmPrefix}/bin:${pkgs.git}/bin:$PATH"
        export NPM_CONFIG_PREFIX="${npmPrefix}"
        ${lib.concatMapStringsSep "\n" (p: "run pi install ${lib.escapeShellArg p}") cfg.piPackages}
      ''
    );
  };
}

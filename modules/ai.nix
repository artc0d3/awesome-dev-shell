# AI coding agents: Claude Code.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.ai;
  npmPrefix = "${config.home.homeDirectory}/.npm-global";

  # Status line for Claude Code. jq and git are baked into the wrapper because
  # Claude Code runs the status line command with the environment it happened to
  # inherit, which is not guaranteed to have either tool on PATH.
  claudeStatusLine = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
    ];
    # The script handles its own failures so that one unresolvable segment drops
    # out instead of blanking the line; strict mode would defeat that.
    bashOptions = [ ];
    text = builtins.readFile ../configs/claude/statusline.sh;
  };
in
{
  options.ads.ai = {
    enable = lib.mkEnableOption "Coding agents";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Pulled from nixpkgs-unstable (see the overlay in flake.nix): claude-code
      # moves fast and the frozen stable channel lags it by weeks. Bump with
      # `nix flake update nixpkgs-unstable`.
      unstable.claude-code
      unstable.nono
      nodejs_24
      rtk
    ];

    # Redirect global npm installs to a user-writable prefix so npm packages
    # can be installed globally without touching the Nix store.
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmPrefix;
    };

    home.sessionPath = [ "${npmPrefix}/bin" ];

    # Nono sandbox profile for Claude Code. Linked out-of-store (to the repo
    # working tree) rather than copied into the Nix store, so they can be tweaked
    # live and committed without a redeploy. See modules/dotfiles.nix.
    xdg.configFile."nono/profiles/yolo-claude.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.ads.dotfilesRoot}/configs/nono/yolo-claude.json";

    # The status line is referenced from settings.json by path, so it needs a
    # stable location outside the Nix store. It is never written to by Claude
    # Code, so an immutable symlink is fine here.
    home.file.".claude/statusline.sh".source = lib.getExe claudeStatusLine;

    # Claude Code settings are seeded, not symlinked: Claude Code writes to
    # ~/.claude/settings.json itself (enabling plugins, /config changes), which
    # an immutable Nix-store symlink would break. The template is copied once on
    # a fresh machine and is the user's to edit from then on — the same approach
    # as ~/.gitconfig in modules/dev-tools.nix. Delete the file and re-activate
    # to pick up a newer template.
    home.activation.seedClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${config.home.homeDirectory}/.claude/settings.json" ]; then
        run mkdir -p "${config.home.homeDirectory}/.claude"
        run install -m 644 ${../configs/claude/settings.json} \
          "${config.home.homeDirectory}/.claude/settings.json"
      fi
    '';

    # Alias for launching Claude Code in yolo mode.
    # TMPDIR is set on the parent env rather than in the profile: nono inherits
    # all env vars by default.
    programs.zsh.shellAliases.yoloclaude = "TMPDIR=/tmp/claude-1000 nono run --profile yolo-claude --allow-cwd -- claude --dangerously-skip-permissions";

    # Pull the shared Nono base profile. The activation PATH is minimal, so add
    # nono explicitly rather than relying on the login shell.
    home.activation.pullNonoProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.unstable.nono}/bin:$PATH"
      run nono pull nolabs-ai/claude
    '';
  };
}

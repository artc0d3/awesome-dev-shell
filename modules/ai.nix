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
  claudeConfigDir = "${config.home.homeDirectory}/.claude";

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

  # Launches Claude Code in yolo mode inside the nono sandbox.
  #
  # TMPDIR points at /tmp/claude-<uid> (granted by the nolabs-ai/claude base
  # profile) because the macOS default under /var/folders is not writable in the
  # sandbox. It is set on the parent env rather than in the profile: nono
  # inherits all env vars by default, and nono itself writes its capability
  # state file (used by `nono why --self`) to $TMPDIR before the sandbox goes
  # up, so the directory has to exist up front. The UID is resolved at runtime
  # instead of being hardcoded, since it differs between WSL (1000) and macOS
  # (501).
  #
  # Inside tmux, the window is renamed to "claude (<dir>)", matching the
  # automatic-rename-format in configs/tmux/tmux.conf. Without this, tmux would
  # show "nono": nono stays in the foreground as the sandbox supervisor, so it
  # is what tmux sees as the pane's command. Renaming a window turns
  # automatic-rename off for it, so the previous name and setting are restored
  # on exit. `tmux` is taken from PATH rather than pinned, as it must match the
  # version of the running server. $TMUX_PANE targets the window the script was
  # started in, even if another window is focused by then.
  yoloClaude = pkgs.writeShellApplication {
    name = "yoloclaude";
    text = ''
      tmp="/tmp/claude-$(id -u)"
      [ -d "$tmp" ] || mkdir -m 700 "$tmp"
      export TMPDIR="$tmp"

      if [ -n "''${TMUX_PANE:-}" ]; then
        prev_name="$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}')"
        prev_auto="$(tmux display-message -p -t "$TMUX_PANE" '#{automatic-rename}')"
        restore_window_name() {
          if [ "$prev_auto" = 1 ]; then
            tmux set-option -w -t "$TMUX_PANE" automatic-rename on
          else
            tmux rename-window -t "$TMUX_PANE" "$prev_name"
          fi
        }
        trap restore_window_name EXIT
        tmux rename-window -t "$TMUX_PANE" "claude ($(basename "$PWD"))"
      fi

      # Not exec'd, so the EXIT trap above still runs once Claude Code quits.
      ${lib.getExe pkgs.unstable.nono} run --profile yolo-claude -- \
        claude --dangerously-skip-permissions "$@"
    '';
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
      yoloClaude
    ];

    # Redirect global npm installs to a user-writable prefix so npm packages
    # can be installed globally without touching the Nix store.
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmPrefix;
      # Keep all Claude Code state, including the .claude.json that otherwise
      # sits loose in $HOME, under ~/.claude. Claude Code saves .claude.json
      # through a sibling temp file (.claude.json.tmp.<pid>.<hex>) and a rename;
      # in $HOME those temp files fall outside the nono sandbox grants, while
      # ~/.claude is granted as a whole by the nolabs-ai/claude base profile.
      # Set globally, not just for yoloclaude, so sandboxed and unsandboxed
      # sessions share the same state.
      CLAUDE_CONFIG_DIR = claudeConfigDir;
    };

    home.sessionPath = [ "${npmPrefix}/bin" ];

    # Nono sandbox profile for Claude Code. Linked out-of-store (to the repo
    # working tree) rather than copied into the Nix store, so it can be tweaked
    # live and committed without a redeploy. See modules/dotfiles.nix.
    #
    # Since the sandbox can write to the working directory, an agent working in
    # this repo could otherwise rewrite the policy that confines its next
    # session. The profile therefore denies its own path. nono resolves the
    # symlink, so the deny covers the file in the repo, wherever it is checked
    # out. It blocks reads as well as writes. On Linux, Landlock can't carve a
    # deny out of a granted directory, so nono refuses to start when the working
    # directory contains the profile (i.e. inside this repo) instead of
    # silently leaving it writable.
    #
    # The profile grants $WORKDIR (the directory nono is started from) directly,
    # which replaces the --allow-cwd flag: workdir.access only sets the access
    # level, and without the flag nono would still ask before sharing the CWD.
    #
    # It also lists "/" under suppress_save_prompt, so when a session ends nono
    # still reports every denied path but no longer offers to save them as
    # grants. Grants belong in the profile JSON, reviewed and committed, not
    # accepted ad hoc at exit.
    #
    # Other choices worth knowing about:
    # - Tool installs (mise) are read-only, and only the parts of ~/.gradle that
    #   Gradle needs to run are writable. Anything the sandbox can write that is
    #   later executed outside it (mise binaries and trusted-configs, Gradle
    #   init.d scripts) would let the agent escape the sandbox.
    # - git commit works without extra grants: /etc/passwd and ~/.gitconfig are
    #   covered by the base profile's system_read_* and git_config groups.
    #   git push does not: ~/.ssh, including the ssh-agent socket, is blocked
    #   by the required deny_credentials group.
    # - The agent commits unsigned. The signing key lives in the main ssh-agent,
    #   which also holds the authentication key, so it is deliberately kept out
    #   of reach. The profile turns commit.gpgsign and tag.gpgsign off through
    #   GIT_CONFIG_COUNT/KEY_n/VALUE_n env vars, which apply inside the sandbox
    #   only. Review the branch, then sign it yourself outside the sandbox:
    #   git rebase --force-rebase --gpg-sign $(git merge-base HEAD main)
    # - open_urls replaces the base profile's list instead of extending it, so
    #   the Claude login origins from nolabs-ai/claude are repeated there.
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

    # One-time move of ~/.claude.json into CLAUDE_CONFIG_DIR (see above), so an
    # existing machine keeps its login, onboarding and per-project state.
    # Skipped when the file is already a symlink or the new location is taken.
    home.activation.migrateClaudeJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${config.home.homeDirectory}/.claude.json" ] \
        && [ ! -L "${config.home.homeDirectory}/.claude.json" ] \
        && [ ! -e "${claudeConfigDir}/.claude.json" ]; then
        run mkdir -p "${claudeConfigDir}"
        run mv "${config.home.homeDirectory}/.claude.json" "${claudeConfigDir}/.claude.json"
      fi
    '';

    # Pull the shared Nono base profile. The activation PATH is minimal, so add
    # nono explicitly rather than relying on the login shell.
    home.activation.pullNonoProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.unstable.nono}/bin:$PATH"
      run nono pull nolabs-ai/claude
    '';
  };
}

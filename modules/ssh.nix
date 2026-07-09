# Cross-platform OpenSSH agent and client (Linux and macOS).
#
# keychain maintains a single long-lived ssh-agent per machine (persisted across
# logins under ~/.keychain), and loads the configured keys into it. A passphrase is
# entered once per reboot when the key is first unlocked; from then on the key stays
# available to all shells — and any process launched from them, e.g. coding agents —
# until the agent is killed. keychain runs from interactive shell init, so it does
# not depend on the systemd --user manager (unreliable under WSL) or any macOS
# launch daemon — it works identically on both platforms.
#
# Only the keys listed below are auto-loaded at login. The agent itself is not locked
# down: extra keys can be added at runtime with `ssh-add`/`keychain <key>` (they live
# until the agent dies, i.e. a `wsl --shutdown`). To auto-load a key on every boot,
# add it here, or `keychain <key>` from ~/.zshrc.local (sourced in shell.nix).
#
# This module handles SSH transport (auth). Git SSH *commit signing* is configured
# alongside git in dev-tools.nix, since it is git configuration.
{
  config,
  lib,
  ...
}:
let
  cfg = config.ads.ssh;
in
{
  options.ads.ssh = {
    enable = lib.mkEnableOption "Linux-native OpenSSH agent and client";
  };

  config = lib.mkIf cfg.enable {
    programs.keychain = {
      enable = true;
      # Key names are resolved under ~/.ssh (absolute paths also work). signing-key is
      # the Git commit-signing key (see dev-tools.nix); it is served by the same agent.
      keys = [
        "id-key"
        "signing-key"
      ];
      extraFlags = [
        "--quiet"
        "--nogui"
      ];
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
      };
    };
  };
}

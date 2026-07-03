# Linux-native OpenSSH agent and client.
#
# Runs ssh-agent as a persistent systemd user service. Once a passphrase-protected
# key is unlocked with `ssh-add`, it stays available across all shells and to any
# process launched from them (e.g. coding agents), until the next reboot.
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
    # Persistent user-level ssh-agent. Also exports SSH_AUTH_SOCK as a session
    # variable so interactive shells and their child processes inherit it.
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      settings."*" = {
        # Cache the auth key in the agent on first use, for the rest of the session.
        AddKeysToAgent = "yes";
      };
    };
  };
}

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
    # Persistent user-level ssh-agent. Home Manager's ssh-agent module also exports
    # SSH_AUTH_SOCK via shell init (~/.zshenv), so shells — and processes launched from
    # them, e.g. coding agents — reach the agent. It is NOT set in the systemd user
    # environment, so units started via `systemctl --user` won't inherit it.
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        # Cache the auth key in the agent on first use, for the rest of the session.
        AddKeysToAgent = "yes";
      };
    };
  };
}

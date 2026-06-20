# 1Password integration for WSL.
# Installs the wslop CLI client and optionally bridges the Windows SSH agent
# (1Password) to a Linux Unix socket so native Linux tools can authenticate
# through the Windows SSH agent.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.op-wsl;

  bridgeScript = pkgs.writeShellScript "ssh-agent-bridge" ''
    relay=$(/sbin/wslpath "$(/mnt/c/Windows/System32/where.exe npiperelay.exe)" | ${pkgs.coreutils}/bin/tr -d '\r')
    echo "Starting SSH agent bridge. Listening on ${cfg.sshAgent.socketPath}, relaying to Windows pipe //./pipe/openssh-ssh-agent"
    echo "Using pipe relay executable: $relay"
    exec ${pkgs.socat}/bin/socat \
      UNIX-LISTEN:${cfg.sshAgent.socketPath},fork \
      EXEC:"$relay -ei -s //./pipe/openssh-ssh-agent",nofork
  '';
in
{
  options.programs.op-wsl = {
    enable = lib.mkEnableOption "1Password CLI (wslop) integration";

    sshAgent = {
      enable = lib.mkEnableOption "SSH agent bridge from Windows 1Password via npiperelay";

      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.ssh/agent.sock";
        description = "Path to the Unix socket for the bridged SSH agent.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.activation.installWslop = lib.hm.dag.entryAfter [ "installPackages" ] ''
        run ${pkgs.uv}/bin/uv tool install wslop
      '';
      home.sessionPath = [ "$HOME/.local/bin" ];
    })

    (lib.mkIf cfg.sshAgent.enable {
      home.sessionVariables.SSH_AUTH_SOCK = cfg.sshAgent.socketPath;

      systemd.user.services.ssh-agent-bridge = {
        Unit.Description = "Bridge Windows SSH agent (1Password) to Linux via npiperelay";
        Service = {
          ExecStartPre = "-${pkgs.coreutils}/bin/rm -f ${cfg.sshAgent.socketPath}";
          ExecStart = toString bridgeScript;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    })
  ];
}

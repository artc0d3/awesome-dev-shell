# WSL-specific configuration.
# Everything in this file is specific to running NixOS under Windows Subsystem for Linux.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Nix-ld is required for tools that download and execute binaries, such as vfox.
  # NixOS doesn't provide a standard dynamic linker at /lib64/ld-linux-x86-64.so.2,
  # so externally downloaded ELF binaries can't run without it.
  # The listed libraries are required for Node.js and JDK.
  nix-ld = {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      alsa-lib
      fontconfig
      freetype
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      zlib
    ];
  };
  podman = {
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    home-manager.users.dev.home.packages = with pkgs; [
      podman-compose
    ];
  };
  # Bubblewrap is required for sandboxing in WSL. Used by Claude Code.
  sandbox = {
    home-manager.users.dev.home.packages = with pkgs; [
      bubblewrap
    ];
  };
  # Bridge the Windows SSH agent (1Password) to a Linux Unix socket via npiperelay.
  # This lets the native Linux ssh client authenticate through the Windows SSH agent,
  # so all tools (git, rsync, ansible, etc.) work without needing ssh.exe wrappers.
  # On first login, the shell imports PATH into the systemd user manager so that
  # services can find Windows executables like npiperelay.exe via WSL interop.
  # Prerequisite: npiperelay.exe must be installed on Windows:
  #   go install github.com/jstarks/npiperelay@latest
  ssh =
    let
      agentSock = "/home/dev/.ssh/agent.sock";
      bridgeScript = pkgs.writeShellScript "ssh-agent-bridge" ''
        relay=$(/sbin/wslpath "$(/mnt/c/Windows/System32/where.exe npiperelay.exe)" | ${pkgs.coreutils}/bin/tr -d '\r')
        echo "Starting SSH agent bridge. Listening on ${agentSock}, relaying to Windows pipe //./pipe/openssh-ssh-agent"
        echo "Using pipe relay executable: $relay"
        exec ${pkgs.socat}/bin/socat \
          UNIX-LISTEN:${agentSock},fork \
          EXEC:"$relay -ei -s //./pipe/openssh-ssh-agent",nofork
      '';
    in
    {
      home-manager.users.dev = {
        home.sessionVariables.SSH_AUTH_SOCK = agentSock;

        systemd.user.services.ssh-agent-bridge = {
          Unit.Description = "Bridge Windows SSH agent (1Password) to Linux via npiperelay";
          Service = {
            ExecStartPre = "-${pkgs.coreutils}/bin/rm -f ${agentSock}";
            ExecStart = toString bridgeScript;
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
  wsl = {
    wsl.enable = true;
    wsl.defaultUser = "dev";
  };
in
lib.mkMerge [
  nix-ld
  podman
  sandbox
  ssh
  wsl
  {
    system.activationScripts.postRebuildHint.text = ''
      echo ""
      echo "################################################################################"
      echo "# System has been rebuilt. To make everything smooth, I recommend to restart the WSL instance:"
      echo "#   exit"
      echo "#   wsl --shutdown"
      echo "#   wsl -d nixos"
      echo "################################################################################"
      echo ""
    '';
  }
]

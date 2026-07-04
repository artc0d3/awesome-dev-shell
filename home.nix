{
  username,
  ...
}:
{
  imports = [
    ./modules/ads-tools.nix
    ./modules/ai.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/op-wsl.nix
    ./modules/podman.nix
    ./modules/shell.nix
    ./modules/shell-tools.nix
    ./modules/ssh.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  ads.ads-tools.enable = true;
  ads.ai.enable = true;
  ads.ai.piPackages = [
    "npm:pi-subagents"
    "npm:pi-web-access"
    "npm:pi-mcp-adapter"
    "npm:@tmustier/pi-usage-extension"
    "git:github.com/DietrichGebert/ponytail@v4.8.4"
  ];
  ads.dev-tools.enable = true;
  ads.neovim-lazyvim.enable = true;
  ads.op-wsl.enable = true;
  ads.podman.enable = true;
  ads.shell.enable = true;
  ads.shell-tools.enable = true;
  ads.ssh.enable = true;
}

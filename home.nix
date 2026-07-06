{
  username,
  pkgs,
  ...
}:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  imports = [
    ./modules/ads-tools.nix
    ./modules/ai.nix
    ./modules/dev-tools.nix
    ./modules/neovim.nix
    ./modules/shell.nix
    ./modules/shell-tools.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";

  ads.ads-tools.enable = true;
  ads.ai.enable = true;
  ads.ai.pi.version = "0.80.2";
  ads.ai.pi.packages = [
    "npm:pi-subagents"
    "npm:pi-web-access"
    "npm:pi-mcp-adapter"
    "npm:@tmustier/pi-usage-extension"
    "git:github.com/DietrichGebert/ponytail@v4.8.4"
  ];
  ads.dev-tools.enable = true;
  ads.neovim-lazyvim.enable = true;
  ads.shell.enable = true;
  ads.shell-tools.enable = true;
  ads.ssh.enable = true;
  ads.tmux.enable = true;
}

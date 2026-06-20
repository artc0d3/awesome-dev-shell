{
  config,
  pkgs,
  lib,
  ...
}:
let
  ads = import ./ads { inherit pkgs; };
in
{
  imports = [
    ./modules/op-wsl.nix
  ];

  home.stateVersion = "25.11";

  home.packages = [
    ads
  ]
  ++ (with pkgs; [
    claude-code
    cloc
    fd
    jq
    neovim
    nixfmt
    ripgrep
    sd
    socat
    uv
    vfox
  ]);

  programs.op-wsl.enable = true;
  programs.op-wsl.sshAgent.enable = true;

  programs.git = {
    enable = true;
    signing.format = null;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    initContent = ''
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
      eval "$(vfox activate zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./configs/starship/config.toml);
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
  };
}

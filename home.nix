{ config, pkgs, ... }: {
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    cloc
    fd
    jq
    neovim
    ripgrep
    sd
    uv
    vfox
  ];

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
  };
  xdg.configFile."starship.toml".source = ./dotfiles/starship.toml;

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

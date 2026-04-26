{ config, pkgs, ... }: {
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    neovim
    vfox
    sd
    ripgrep
    jq
    cloc
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
}

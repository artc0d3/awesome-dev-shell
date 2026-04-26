user: { config, pkgs, ... }: {
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    neovim
  ];

  programs.git = {
    enable = true;
    signing.format = null;
    settings.user.name = user.gitName;
    settings.user.email = user.gitEmail;
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

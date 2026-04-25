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
  };
}

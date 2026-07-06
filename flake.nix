{
  description = "Awesome Dev Shell — a batteries-included terminal environment managed by Home Manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    {
      homeConfigurations.wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          username = "dev"; # ← set this to your WSL username
        };
        modules = [ ./home.nix ./home-wsl.nix ];
      };

      homeConfigurations.mac = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          username = "changeme"; # ← set this to your macOS username
        };
        modules = [ ./home.nix ./home-mac.nix ];
      };
    };
}

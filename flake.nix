{
  description = "Awesome Dev Shell — a batteries-included terminal environment managed by Home Manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "claude-code"
            ];
        };
        extraSpecialArgs = {
          username = "dev";
        };
        modules = [ ./home.nix ];
      };
    };
}

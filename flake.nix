{
  description = "Awesome Dev Shell — a batteries-included terminal environment managed by Home Manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # A second, fast-moving channel. The stable channel freezes package versions
    # at release time and only receives occasional backports, so fast-moving
    # tools (e.g. claude-code) lag it by weeks. nixos-unstable is bumped by an
    # automated bot — often within a day of upstream — and is exposed to modules
    # as `pkgs.unstable.*` via the overlay below. Refresh it with
    # `nix flake update nixpkgs-unstable`.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      # Expose the unstable channel as `pkgs.unstable` so individual packages can
      # opt into it without turning the whole environment unstable. Use it only
      # for packages that genuinely need to track upstream closely.
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ unstableOverlay ];
        };

      mkHome =
        {
          system,
          username,
          extraModules,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ] ++ extraModules;
        };
    in
    {
      homeConfigurations.wsl = mkHome {
        system = "x86_64-linux";
        username = "dev"; # ← set this to your WSL username
        extraModules = [ ./home-wsl.nix ];
      };

      homeConfigurations.mac = mkHome {
        system = "aarch64-darwin";
        username = "changeme"; # ← set this to your macOS username
        extraModules = [ ./home-mac.nix ];
      };
    };
}

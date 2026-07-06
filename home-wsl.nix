{
  imports = [
    ./modules/op-wsl.nix
    ./modules/podman.nix
  ];

  ads.op-wsl.enable = true;
  ads.podman.enable = true;
}

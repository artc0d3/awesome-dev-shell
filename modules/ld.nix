# Nix-ld is required for tools that download and execute binaries, such as vfox.
# NixOS doesn't provide a standard dynamic linker at /lib64/ld-linux-x86-64.so.2,
# so externally downloaded ELF binaries can't run without it.
# The listed libraries are required for Node.js and JDK.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ads.nix-ld-libs;
in
{
  options.ads.nix-ld-libs = {
    enable = lib.mkEnableOption "nix-ld with libraries for Node.js and JDK";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      alsa-lib
      fontconfig
      freetype
      stdenv.cc.cc.lib
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      zlib
    ];
  };
}

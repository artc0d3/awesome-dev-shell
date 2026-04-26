# Awesome Dev Shell (ADS) CLI tool.
# Provides opinionated configuration templates for dev tools (e.g. "ads config init claude").
{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "ads";
  src = ./.;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/share/ads
    cp -r templates $out/share/ads/
    cp ads.sh $out/bin/ads
    chmod +x $out/bin/ads
    wrapProgram $out/bin/ads \
      --set ADS_TEMPLATES_DIR $out/share/ads/templates
  '';
}

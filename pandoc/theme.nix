{pkgs, lib, latex, ...}: let
  src = pkgs.fetchFromGitHub {
    repo = "mtheme";
    owner = "matze";
    rev = "2fa6084b9d34fec9d2d5470eb9a17d0bf712b6c8";
    sha256 = "sha256-1HptXntlCUtXwhKuenuVjsj4K3oK5eOsNPZ9+nwSczg=";
  };
in pkgs.stdenv.mkDerivation {
  name = "metropolis-theme";
  inherit src;
  propagatedBuildInputs = with pkgs; [
    latex
  ];
  installPhase = ''
    mkdir -p $out
    mv *.sty $out/
  '';
}

{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.11;
  };

  outputs = inputs: with inputs; let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    lib = pkgs.lib;
    latex = pkgs.texlive.combined.scheme-full;
    theme = import ./theme.nix { inherit pkgs lib latex; };
    script = pkgs.writeShellScript "generate_presentation" ''
      export PATH=$PATH:${pkgs.pandoc}/bin:${latex}/bin
      ls ${theme}/*
      exit 0;
      pandoc -f markdown -t beamer ${./smt_talk.md} -o smt_talk.latex
    '';
  in {
    apps.${system}.default = { type = "app"; program = "${script}"; };
    packages.${system}.default = script;
    lib.${system} = {
      mkPresentation = {name, src, ...}: pkgs.stdenv.mkDerivation {
        inherit name src;
        phases = ["buildPhase" "installPhase"];
        propagatedBuildInputs = [
          latex
          pkgs.pandoc
        ];
        buildPhase = ''
          pandoc -f markdown -t beamer ${src} -o ${name}.pdf
        '';
        installPhase = ''
          mv ./${name}.pdf $out
        '';
      };
    };
  };
}

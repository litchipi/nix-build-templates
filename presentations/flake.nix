{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.11;
  };

  outputs = inputs: with inputs; let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    lib = pkgs.lib;

    backend = import ./backslide.nix { inherit pkgs lib; };
    mkPresentation = {name, src, ...}@args: pkgs.stdenv.mkDerivation {
      name = "${name}.pdf";
      inherit src;
      buildInputs = [ backend.package ];

      phases = ["buildPhase" "installPhase"];
      buildPhase = backend.build args;
      installPhase = backend.install args;
    };

  in {
    lib.${system} = { inherit mkPresentation; };
    packages.${system}.default = mkPresentation {
      name = "test_presentation";
      src = ./test.md;      
    };
    apps.${system}.default = { type = "app"; program = "${backend.dev 4100}"; };
    shell.${system}.default = pkgs.lib.mkShell {
      buildInputs = [ backend.package ];
    };
  };
}
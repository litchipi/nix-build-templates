{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs { inherit system; };
    typst = import ./typst.nix pkgs;
  in {
    overlays.default = (self: super: {
      lib = super.lib // {
        inherit typst;
      };
    });
    devShells.default = pkgs.mkShell {
      SUIJI="${typst.typstpkgs.suiji.src}";
    };
  });
}

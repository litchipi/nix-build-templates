{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs { inherit system; };
    nodepkgs = pkgs.nodePackages_latest;

    name = "project";
    deps = with pkgs; [
    ];
    node_deps = with nodepkgs; [
      nodejs
    ];
  in {
    devShells.default = pkgs.mkShell {
      buildInputs = deps ++ node_deps;
    };
  });
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs: with inputs; flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ rust-overlay.overlays.default ];
    };

    rustpkg = pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    };

    deps = with pkgs; [ rustpkg ];

  in {
    # TODO  Build a package using nix, and start it
    devShells.default = pkgs.mkShell {
      buildInputs = deps;
    };
  });
}

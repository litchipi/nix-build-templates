{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs { inherit system; };
    python_version = pkgs.python312;
    custom_pkgs = (import ./packages.nix pkgs python_version.pkgs);
    pythonpkg = python_version.withPackages (p: with p; [
    ]);

    start = pkgs.writeShellScript "start" ''
      ${pythonpkg}/bin/python ./script.py
    '';

  in {
    apps.default = {
      type = "app";
      program = "${start}";
    };

    devShells.default = pkgs.mkShell {
      buildInputs = [
        pythonpkg
      ];
      PYTHONPATH = "${pythonpkg}/${pythonpkg.sitePackages}:$PYTHONPATH";
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib$LD_LIBRARY_PATH";
    };
  });
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs { inherit system; };
    lib = pkgs.lib;

    python_version = pkgs.python310;
    python_packages_version = pkgs.python310Packages;
    custom_pkgs = (import ./python-packages.nix pkgs python_packages_version);
    pythonpkg = python_version.withPackages (p: with p; [
      pip
      numpy
      tensorflow
      custom_pkgs.tensorflow-hub
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

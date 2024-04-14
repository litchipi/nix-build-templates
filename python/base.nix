{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs { inherit system; };

    python_version = pkgs.python310;
    pythonpkg = python_version.withPackages (p: with p; [
    ]);

    name = "my_script";
    deps = with pkgs; [
      pythonpkg
    ];

    start = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = deps;
      text = ''
        ${pythonpkg}/bin/python ./main.py
      '';
    };

  in {
    packages.default = start;
    apps.default = {
      type = "app";
      program = "${start}/bin/${name}";
    };

    devShells.default = pkgs.mkShell {
      buildInputs = deps;
      PYTHONPATH = "${pythonpkg}/${pythonpkg.sitePackages}:$PYTHONPATH";
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib$LD_LIBRARY_PATH";
    };
  });
}

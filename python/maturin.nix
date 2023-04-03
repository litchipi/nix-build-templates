{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ inputs.rust-overlay.overlays.default ];
    };
    lib = pkgs.lib;

    python_version = pkgs.python310;
    wheel_tail = "cp310-cp310-linux_x86_64";  # Change if python_version changes

    custom_rust_toolchain = pkgs.rust-bin.stable."1.68.2".default;
    craneLib = (inputs.crane.mkLib pkgs).overrideToolchain custom_rust_toolchain;
    project_name = (craneLib.crateNameFromCargoToml { cargoToml = ./Cargo.toml; }).pname;
    project_version = (craneLib.crateNameFromCargoToml { cargoToml = ./Cargo.toml; }).version;
    crate_cfg = {
      src = craneLib.cleanCargoSource (craneLib.path ./.);
      nativeBuildInputs = [ python_version ];
      # doCheck = true;
      # buildInputs = [];
    };
    crate_artifacts = craneLib.buildDepsOnly (crate_cfg // {
      pname = "${project_name}-artifacts";
      version = project_version;
    });
    crate_lib = (craneLib.buildPackage (crate_cfg // {
      pname = project_name;
      version = project_version;
      cargoArtifacts = crate_artifacts;
    })).overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.maturin ];
      buildPhase = old.buildPhase + ''
        maturin build --offline --target-dir ./target
      '';
      installPhase = old.installPhase + ''
        cp target/wheels/${project_name}-${project_version}-*.whl $out/
      '';
    });
  in rec {
    packages = {
      default = crate_lib;
      pythonpkg = python_version.withPackages (ps: [
        (lib.python_package ps)
      ]);
    };
    lib = {
      python_package = ps: ps.buildPythonPackage rec {
        pname = project_name;
        format = "wheel";
        version = project_version;
        src = "${crate_lib}/${project_name}-${project_version}-${wheel_tail}.whl";
        doCheck = false;
        pythonImportsCheck = [ project_name ];
      };
    };
  });
}

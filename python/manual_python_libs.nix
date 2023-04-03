# Pkgs:   nixpkgs { inherit system };
# Pythonpkg: pkgs.python310Packages (for python 3.10);

pkgs: pythonpkg: let
  lib = pkgs.lib;
in {
  tensorflow-hub = pythonpkg.buildPythonPackage rec {
    pname = "tensorflow_hub";
    version = "0.12.0";
    format = "wheel";

    disabled = pythonpkg.pythonOlder "3.9";

    src = pythonpkg.fetchPypi rec {
      inherit pname version format;
      sha256 = "sha256-gi/l9zOMle/MOlNAEcZonkMJuiRZ3vhxlBecTeim4fw=";
      dist = python;
      python = "py2.py3";
      #abi = "none";
      #platform = "any";
    };

    propagatedBuildInputs = with pythonpkg; [
      protobuf
      numpy
      tensorflow
      keras
    ];

    pythonImportsCheck = [ "tensorflow_hub" ];
  };
}

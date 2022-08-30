# Pkgs: nixpkgs { inherit system };
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

  # https://files.pythonhosted.org/packages/29/32/899878aa65cae5429f30449cdda61224e3f4319e6a155027bc3af4c3f07b/tensorflow_hub-0.12.0-py2.py3-none-any.whl

    # postPatch = ''
    #   # no coverage reports
    #   sed -i "/addopts/d" tox.ini
    # '';

    propagatedBuildInputs = with pythonpkg; [
      protobuf
      numpy
      tensorflow
      keras
    ];

    # checkInputs = [
    #   pytestCheckHook
    #   pytest-mock
    #   pytz
    #   simplejson
    # ];

    # ParserError: Could not parse timezone expression "America/Nuuk"
    # disabledTests = [
    #   "test_parse_tz_name_zzz"
    # ];

    pythonImportsCheck = [ "tensorflow_hub" ];
  };
}

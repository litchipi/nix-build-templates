{pkgs, lib, ...}: let
  name = "backslide";
  src = pkgs.fetchFromGitHub {
    owner = "sinedied";
    repo = "backslide";
    rev = "3.1.0";
    sha256 = "sha256-NmUXHDSp7JE6vQ1dlckjY5baFThY4f5UVWdFF8XKhME=";
  };
  backslide = pkgs.buildNpmPackage {
    inherit name src;
    npmDepsHash = "sha256-IZ0pr+BVdIw0YWl8dgWrmfkJhHSRD/Av40khou5qjm0=";
    dontNpmBuild = true;
  };
in
{
  addBuildInputs = [
  ];
  package = backslide;
  build = { name, src, ... }: ''
    cp -r ${./template} ./template
    cp $src ./${name}.md
    bs export -o ./dist
  '';
  install = { ... }: ''
    mv dist/ $out
  '';
  dev = port: pkgs.writeShellScript "backslide_dev" ''
    if ! [ -e ./template ]; then
      ln -s ${./template} ./template
    fi
    ${backslide}/bin/bs serve . -p ${builtins.toString port}
    rm ./template
  '';
}

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
  package = backslide;
  build = { name, src, ... }: ''
    cp -r ${./template} ./template
    cp $src ./${name}.md
    ls -l
    bs export
  '';
  install = { ... }: ''
    mv dist/ $out
  '';
  dev = port: pkgs.writeShellScript "backslide_dev" ''
    ln -s ${./template} ./template
    ${backslide}/bin/bs serve . -p ${builtins.toString port}
    rm ./template
  '';
}

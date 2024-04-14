{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { inherit system; };

    get_font = pkgs.writeShellScript "get-dafont-font" ''
    if [ $# -ne 1 ]; then
      echo "Usage: $0 <font name>"
      exit 1;
    fi
    if [ -z "$FONT_OUTPUT_DIR" ]; then
      echo "Please set FONT_OUTPUT_DIR in order to get fonts"
      exit 1;
    fi
    FONT_NAME="$1"
    rm -rf "$FONT_OUTPUT_DIR/$FONT_NAME"
    mkdir -p "$FONT_OUTPUT_DIR/$FONT_NAME"
    set -e
    wget "https://dl.dafont.com/dl/?f=$FONT_NAME" -O "$FONT_OUTPUT_DIR/$FONT_NAME.zip"
    unzip "$FONT_OUTPUT_DIR/$FONT_NAME.zip" -d "$FONT_OUTPUT_DIR/$FONT_NAME"
    rm "$FONT_OUTPUT_DIR/$FONT_NAME.zip"
    '';

    mkScript = script: { type = "app"; program = "${script}"; };
  in {
    apps.${system} = {
      get_font = mkScript get_font;
      default = mkScript (pkgs.writeShellScript "compile-presentation" ''
        echo "$@ $#"
        if [ $# -ne 2 ]; then
          echo "Usage: $0 <typst file> <fonts dir>";
          exit 1;
        fi
        ${pkgs.typst}/bin/typst compile --font-path "$2" --root . "$1"
      '');
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ pkgs.typst get_font ];
      shellHook = ''
        export TYPST_FONT_PATHS=$(realpath ./.fonts)
        echo "Typst fonts path is $TYPST_FONT_PATHS"
      '';
    };
  };
}


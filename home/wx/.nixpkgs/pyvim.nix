{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  neovim = pkgs.neovim.override {
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ coc-nvim ];
        };
      };
  };
in
stdenv.mkDerivation {
  name = "pyvim";
  buildInputs = [
    neovim
  ] ++ (with python3Packages; [
    python-language-server
  ]);
}

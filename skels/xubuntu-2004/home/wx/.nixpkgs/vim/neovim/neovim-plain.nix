with import <nixpkgs> {};
{ python3, pkgs, name ? "neovim-plain" }:
let
  newpkgs = import (builtins.fetchTarball { # TODO either wait for nvim 0.5 to be released or build it
    name = "nixpkgs-20-09";
    url = "https://github.com/NixOS/nixpkgs/archive/f03649db6a1f2dc079004020c3287aa679769a75.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1ryc565jyv70md0jn39psdsxsq3a205gh30y85f7x3z84v7ix1i4";
  }) {};
  common_vim_preferences = builtins.readFile ../common.vimrc;
  neovim_preferences = builtins.readFile ./neovim.vimrc;

  my_neovim = newpkgs.neovim.override {
    configure = {
      customRC = ''
      '' + common_vim_preferences + neovim_preferences;

      packages.myVimPackage = with newpkgs.vimPlugins; {
        start = [ fzf-vim fzfWrapper ];
      };
    };
  };
in pkgs.symlinkJoin { # https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
  name = name;
  paths = [ my_neovim ];
  postBuild = ''ln -s $out/bin/nvim $out/bin/${name}'';
}

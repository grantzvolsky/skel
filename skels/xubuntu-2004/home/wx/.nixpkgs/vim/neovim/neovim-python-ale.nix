{ python3, pkgs, name ? "neovim-python" }:
let
  newpkgs = import (builtins.fetchTarball { # TODO either wait for nvim 0.5 to be released or build it
    name = "nixpkgs-20-09";
    url = "https://github.com/NixOS/nixpkgs/archive/f03649db6a1f2dc079004020c3287aa679769a75.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1ryc565jyv70md0jn39psdsxsq3a205gh30y85f7x3z84v7ix1i4";
  }) {};

  common_vim_preferences = builtins.readFile ../common.vimrc;
  neovim_preferences = builtins.readFile ./neovim.vimrc;

  #my_python = (python3.withPackages(ps: [
  #  ps.numpy
  #  ps.pandas
  #]));

  ale_neovim_python_preferences = ''
    let g:ale_linters = {'python': ['pyright']}
    let g:ale_fixers = {'python': ['black']}

    let g:deoplete#enable_at_startup = 1
    "call deoplete#custom#option('sources', { '_': ['ale'], })

    "let g:ale_completion_enabled = 1 " this is an alternative to deoplete

    set signcolumn=yes
    hi clear SignColumn

    nnoremap <silent> gh :ALEHover<CR>
    nnoremap <silent> gd :ALEGoToDefinition<CR>
    nnoremap <silent> gr :ALEFindReferences<CR>
    nnoremap <silent> gf :ALEFix<CR>
  '' + common_vim_preferences + neovim_preferences;

  neovim_python = newpkgs.neovim.override {
    configure = {
      customRC = ale_neovim_python_preferences;
      packages.myVimPackage = with newpkgs.vimPlugins; {
        start = [
          ale
          deoplete-nvim
          fzf-vim
          fzfWrapper
        ];
      };
    };
  };
in pkgs.symlinkJoin {
  name = name;
  paths = [ ];
  buildInputs = [ neovim_python newpkgs.python3.pkgs.black newpkgs.nodePackages.pyright ];
  postBuild = ''
    mkdir $out/bin
    ln -s ${newpkgs.python3.pkgs.black}/bin/black $out/bin/black
    ln -s ${newpkgs.nodePackages.pyright}/bin/pyright $out/bin/pyright
    ln -s ${newpkgs.nodePackages.pyright}/bin/pyright-langserver $out/bin/pyright-langserver
    ln -s ${neovim_python}/bin/nvim $out/bin/${name}
  '';
}

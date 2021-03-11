# Pros: go to definition works better than in ALE because e.g. os.path<gd> lets you choose between ntpath.py and posixpath.py
# Cons: completion isn't configured yet

{ python3, pkgs, name ? "neovim-python-lcn" }:
let
  newpkgs = import (builtins.fetchTarball { # TODO either wait for nvim 0.5 to be released or build it
    name = "nixpkgs-20-09";
    url = "https://github.com/NixOS/nixpkgs/archive/f03649db6a1f2dc079004020c3287aa679769a75.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1ryc565jyv70md0jn39psdsxsq3a205gh30y85f7x3z84v7ix1i4";
  }) {};

  common_vim_preferences = builtins.readFile ../common.vimrc;
  neovim_preferences = builtins.readFile ./neovim.vimrc;

  my_python = (python3.withPackages(ps: [
    ps.python-language-server

    #ps.pyls-mypy # type checking
    ps.pyls-isort # import sorting
    ps.pyls-black # code formatting

    ps.numpy
    ps.pandas
  ]));

  languageclient_neovim_python_preferences = ''
    let g:LanguageClient_serverCommands = {
      \ 'python': ['pyls']
      \ }
    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
    nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
    nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>
    nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
    nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
    nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
    set signcolumn=yes
  '' + common_vim_preferences + neovim_preferences;

  neovim_python = newpkgs.neovim.override {
    configure = {
      customRC = languageclient_neovim_python_preferences;
      packages.myVimPackage = with newpkgs.vimPlugins; {
        start = [
          fzf-vim
          fzfWrapper
          #ale
          LanguageClient-neovim
        ];
      };
    };
  };
in pkgs.symlinkJoin {
  name = name;
  paths = [ ];
  buildInputs = [ neovim_python my_python ];
  postBuild = ''
    mkdir $out/bin
    ln -s ${my_python}/bin/pyls $out/bin/pyls
    ln -s ${neovim_python}/bin/nvim $out/bin/${name}
  '';
}

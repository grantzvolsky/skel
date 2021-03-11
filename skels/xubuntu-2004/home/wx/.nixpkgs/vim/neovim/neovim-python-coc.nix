# Instructions:
# open nvim-python-coc and run :CocInstall coc-pyright
# the python extension should now be installed in $HOME/.config/coc/extensions/
#
# Pros: is blazing fast; just works
# Cons: go-to-definition sometimes goes to a typeshed instead of the source, e.g. for os.path
#   (though in this case it's easy to get to the right source via os.py)

{ python3, pkgs, name ? "neovim-python-coc" }:
let
  newpkgs = import (builtins.fetchTarball { # TODO either wait for nvim 0.5 to be released or build it
    name = "nixpkgs-20-09";
    url = "https://github.com/NixOS/nixpkgs/archive/f03649db6a1f2dc079004020c3287aa679769a75.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1ryc565jyv70md0jn39psdsxsq3a205gh30y85f7x3z84v7ix1i4";
  }) {};

  common_vim_preferences = builtins.readFile ../common.vimrc;
  neovim_preferences = builtins.readFile ./neovim.vimrc;

  # TODO configure a formatting provider; the below Python bundle may or may not be necessary
  my_python = (python3.withPackages(ps: [
    #ps.pyls-mypy # type checking
    ps.pyls-isort # import sorting
    ps.pyls-black # code formatting

    ps.numpy
    ps.pandas
    ps.xmltodict
  ]));

  coc_neovim_python_preferences = ''
    " Use <c-space> to trigger completion.
    inoremap <silent><expr> <c-space> coc#refresh()
    nmap <leader>qf  <Plug>(coc-fix-current)

    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " fix purple text on purple background
    hi link CocFloating markdown
  '' + common_vim_preferences + neovim_preferences;

  neovim_python = newpkgs.neovim.override {
    configure = {
      customRC = coc_neovim_python_preferences;
      packages.myVimPackage = with newpkgs.vimPlugins; {
        start = [
          coc-nvim
          fzf-vim
          fzfWrapper
          #ale
        ];
      };
    };
  };
in pkgs.symlinkJoin {
  name = name;
  paths = [ ];
  buildInputs = [ neovim_python my_python newpkgs.nodejs newpkgs.yarn ];
  postBuild = ''
    mkdir $out/bin
    ln -sn ${newpkgs.nodejs}/bin/node $out/bin/node
    ln -sn ${newpkgs.yarn}/bin/yarn $out/bin/yarn
    ln -s ${neovim_python}/bin/nvim $out/bin/${name}
  '';
}

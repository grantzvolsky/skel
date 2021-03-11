/*
https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
Save this file to ~/default.nix or your preferred path (make sure to
change the location in the update-profile script if you choose a
different place).
Install using `nix-env -f ~ --set`, from then on use `update-profile`.
*/

{ pkgs ? import <nixpkgs> {}
, name ? "user-env"
}: with pkgs;

let
  vim-ep = callPackage ~/.nixpkgs/vim/neovim/neovim-python-coc.nix { name = "ep"; };
  vim-aliases = [ vim-ep ];

  #vim8-python = callPackage ~/.nixpkgs/vim/vim8/vim8-python.nix { name = "vim8-python"; };
  #vim8s = [ vim8-python ];

  neovim-plain = callPackage ~/.nixpkgs/vim/neovim/neovim-plain.nix { name = "neovim-plain"; };
  neovim-python-ale = callPackage ~/.nixpkgs/vim/neovim/neovim-python-ale.nix { name = "neovim-python-ale"; };
  neovim-python-coc = callPackage ~/.nixpkgs/vim/neovim/neovim-python-coc.nix { name = "neovim-python-coc"; };
  neovim-python-lcn = callPackage ~/.nixpkgs/vim/neovim/neovim-python-lcn.nix { name = "neovim-python-lcn"; };
  neovims = [ neovim-plain neovim-python-ale neovim-python-coc neovim-python-lcn ];
#  cue = callPackage ~/.nixpkgs/my-cue.nix {};
in buildEnv {
  inherit name;
  extraOutputsToInstall = ["out" "bin" "lib"];
  paths = vim-aliases ++ neovims ++ [
    #docker_19_03
    #dotnet-sdk_3
    fzf
    git
    jq
    #go
    #kubectl
    nix # If not on NixOS, this is important!
    #nodejs
    #pass TODO figure out why nix pass doesn't come with bash completion & the standard tree command
    ripgrep
    shellcheck
    tmux
    vim-ep
    vscode

    (writeScriptBin "update-profile" ''
      #!${stdenv.shell}
      nix-env --set -f ~/ --argstr name "$(whoami)-user-env-$(date -I)"
    '')

    # Manifest to make sure imperative nix-env doesn't work (otherwise it will overwrite the profile, removing all packages other than the newly-installed one).
    (writeTextFile {
      name = "break-nix-env-manifest";
      destination = "/manifest.nix";
      text = ''
        throw ''\''
          Your user environment is a buildEnv which is incompatible with
          nix-env's built-in env builder. Edit your home expression and run
          update-profile instead!
        ''\''
      '';
    })
    # To allow easily seeing which nixpkgs version the profile was built from, place the version string in ~/.nix-profile/nixpkgs-version
    (writeTextFile {
      name = "nixpkgs-version";
      destination = "/nixpkgs-version";
      text = lib.version;
    })
  ];
}

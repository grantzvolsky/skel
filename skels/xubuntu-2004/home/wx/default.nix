/*
https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
Save this file to ~/default.nix or your preferred path (make sure to
change the location in the update-profile script if you choose a
different place).
Install using `nix-env -f ~ --set`, from then on use `update-profile`.
*/

# Pinned to this version because it comes with neovim 0.5
with import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/d924c2327b5a0b083035c168549aa40685ed47a8.tar.gz") {};

let
  name = "user-env";
#  cue = callPackage ~/.nixpkgs/my-cue.nix {};
in buildEnv {
  inherit name;
  extraOutputsToInstall = ["out" "bin" "lib"];
  paths = [
    #docker_19_03
    #dotnet-sdk_3
    fzf
    git
    jq
    #go
    #kubectl
    neovim
    nix # If not on NixOS, this is important!
    #nodejs
    #pass TODO figure out why nix pass doesn't come with bash completion & the standard tree command
    ripgrep
    shellcheck
    tmux

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

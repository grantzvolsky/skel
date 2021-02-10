{ stdenv, lib, callPackage, fetchurl, isInsiders ? false }:

let
  inherit (stdenv.hostPlatform) system;

  plat = {
    x86_64-linux = "linux-x64";
    x86_64-darwin = "darwin";
  }.${system};

  archive_fmt = if system == "x86_64-darwin" then "zip" else "tar.gz";

  sha256 = {
    x86_64-linux = "7beb42d9d7592ae8725a38b3548b87687f1e8449df13d8ec526ae11e38879c01";
    x86_64-darwin = "";
  }.${system};
in
  callPackage ./generic.nix rec {
    # The update script doesn't correctly change the hash for darwin, so please:
    # nixpkgs-update: no auto update

    # Please backport all compatible updates to the stable release.
    # This is important for the extension ecosystem.
    version = "1.19.0";
    pname = "azuredatastudio";

    executableName = "azuredatastudio" + lib.optionalString isInsiders "-insiders";
    longName = "Azure Data Studio" + lib.optionalString isInsiders " - Insiders";
    shortName = "azuredatastudio" + lib.optionalString isInsiders " - Insiders";

    src = fetchurl {
      name = "AzureDataStudio_${version}_${plat}.${archive_fmt}";
      url = "https://azuredatastudio-update.azurewebsites.net/${version}/${plat}/stable";
      inherit sha256;
    };

    sourceRoot = "";

    meta = with stdenv.lib; {
      description = ''
        Azure Data Studio
      '';
      longDescription = ''
        Azure Data Studio
      '';
      homepage = "https://github.com/microsoft/azuredatastudio";
      downloadPage = "https://docs.microsoft.com/en-us/sql/azuredatastudio/download-azuredatastudio";
      license = licenses.unfree;
      maintainers = with maintainers; [ gzvolsky ];
      platforms = [ "x86_64-linux" "x86_64-darwin" ];
    };
  }

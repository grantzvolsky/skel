{ stdenv, lib, makeDesktopItem
, libkrb5, lttng-ust, curl
, unzip, libsecret, libXScrnSaver, wrapGAppsHook
, gtk2, atomEnv, at-spi2-atk, autoPatchelfHook
, systemd, fontconfig

# Attributes inherit from specific versions
, version, src, meta, sourceRoot
, executableName, longName, shortName, pname
}:

let
  inherit (stdenv.hostPlatform) system;
in
  stdenv.mkDerivation {

    inherit pname version src sourceRoot;

    passthru = {
      inherit executableName;
    };

    desktopItem = makeDesktopItem {
      name = executableName;
      desktopName = longName;
      comment = "Azure Data Studio";
      genericName = "Text Editor";
      exec = "${executableName} %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "text/plain;inode/directory;";
      extraEntries = ''
        StartupWMClass=${shortName}
        Actions=new-empty-window;
        Keywords=azure data studio;
        [Desktop Action new-empty-window]
        Name=New Empty Window
        Exec=${executableName} --new-window %F
        Icon=code
      '';
    };

    urlHandlerDesktopItem = makeDesktopItem {
      name = executableName + "-url-handler";
      desktopName = longName + " - URL Handler";
      comment = "Azure Data Studio";
      genericName = "Text Editor";
      exec = executableName + " --open-url %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "x-scheme-handler/code;";
      extraEntries = ''
        NoDisplay=true
        Keywords=azure data studio;
      '';
    };

    buildInputs = (if stdenv.isDarwin
      then [ unzip ]
      else [ gtk2 at-spi2-atk wrapGAppsHook ] ++ atomEnv.packages)
        ++ [ libsecret libXScrnSaver libkrb5 lttng-ust curl ];

    # TODO apparently we need more runtime dependencies
    runtimeDependencies = lib.optional (stdenv.isLinux) [ systemd.lib fontconfig.lib ];

    nativeBuildInputs = lib.optional (!stdenv.isDarwin) autoPatchelfHook;

    dontBuild = true;
    dontConfigure = true;

    installPhase =
      if system == "x86_64-darwin" then ''
        mkdir -p "$out/Applications/${longName}.app" $out/bin
        cp -r ./* "$out/Applications/${longName}.app"
        ln -s "$out/Applications/${longName}.app/Contents/Resources/app/bin/azuredatastudio" $out/bin/${executableName}
      '' else ''
        mkdir -p $out/lib/azuredatastudio $out/bin
        cp -r ./* $out/lib/azuredatastudio
        ln -s $out/lib/azuredatastudio/bin/${executableName} $out/bin
        mkdir -p $out/share/applications
        ln -s $desktopItem/share/applications/${executableName}.desktop $out/share/applications/${executableName}.desktop
        ln -s $urlHandlerDesktopItem/share/applications/${executableName}-url-handler.desktop $out/share/applications/${executableName}-url-handler.desktop
        mkdir -p $out/share/pixmaps
        #cp $out/lib/azuredatastudio/resources/app/resources/linux/code.png $out/share/pixmaps/code.png # commented out to avoid collision with vscode TODO resolve
        # Override the previously determined VSCODE_PATH with the one we know to be correct
        sed -i "/ELECTRON=/iVSCODE_PATH='$out/lib/azuredatastudio'" $out/bin/${executableName}
        grep -q "VSCODE_PATH='$out/lib/azuredatastudio'" $out/bin/${executableName} # check if sed succeeded
      '';

    inherit meta;
  }

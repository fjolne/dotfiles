{ lib
, stdenvNoCC
, fetchurl
, appimageTools
, makeWrapper
, writeScript
, undmg
,
}:
let
  pname = "cursor";
  version = "0.46.9";

  inherit (stdenvNoCC) hostPlatform;

  sources = {
    x86_64-linux = fetchurl {
      url = "https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/client/linux/x64/appimage/Cursor-0.46.9-3395357a4ee2975d5d03595e7607ee84e3db0f2c.deb.glibc2.25-x86_64.AppImage";
      hash = "sha256-GblFuJL2x+VIso8vK/TR43erE1O0TpfAANAykfJBGNA=";
    };
    # aarch64-linux = fetchurl {
    #   url = "https://download.todesktop.com/230313mzl4w4u92/cursor-0.45.14-build-250219jnihavxsz-arm64.AppImage";
    #   hash = "sha256-8OUlPuPNgqbGe2x7gG+m3n3u6UDvgnVekkjJ08pVORs=";
    # };
    # x86_64-darwin = fetchurl {
    #   url = "https://download.todesktop.com/230313mzl4w4u92/Cursor%200.45.14%20-%20Build%20250219jnihavxsz-x64.dmg";
    #   hash = "sha256-NyDY74PZjSjpuTSVaO/l9adPcLX1kytyrFGQjJ/8WcQ=";
    # };
    # aarch64-darwin = fetchurl {
    #   url = "https://download.todesktop.com/230313mzl4w4u92/Cursor%200.45.14%20-%20Build%20250219jnihavxsz-arm64.dmg";
    #   hash = "sha256-A503TxDDFENqMnc1hy/lMMyIgC7YwwRYPJy+tp649Eg=";
    # };
  };

  source = sources.${hostPlatform.system};

  # Linux -- build from AppImage
  appimageContents = appimageTools.extractType2 {
    inherit version pname;
    src = source;
  };

  wrappedAppimage = appimageTools.wrapType2 {
    inherit version pname;
    src = source;
  };

in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = if hostPlatform.isLinux then wrappedAppimage else source;

  nativeBuildInputs =
    lib.optionals hostPlatform.isLinux [ makeWrapper ]
    ++ lib.optionals hostPlatform.isDarwin [ undmg ];

  sourceRoot = lib.optionalString hostPlatform.isDarwin ".";

  # Don't break code signing
  dontUpdateAutotoolsGnuConfigScripts = hostPlatform.isDarwin;
  dontConfigure = hostPlatform.isDarwin;
  dontFixup = hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/

    ${lib.optionalString hostPlatform.isLinux ''
      cp -r bin $out/bin

      # desktop icon
      mkdir -p $out/share
      cp -a ${appimageContents}/usr/share/icons $out/share/
      install -Dm 644 ${appimageContents}/cursor.desktop -t $out/share/applications/

      # wayland fixes
      wrapProgram $out/bin/cursor \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update"
    ''}

    ${lib.optionalString hostPlatform.isDarwin ''
      APP_DIR="$out/Applications"
      CURSOR_APP="$APP_DIR/Cursor.app"
      mkdir -p "$APP_DIR"
      cp -Rp Cursor.app "$APP_DIR"
      mkdir -p "$out/bin"
      cat << EOF > "$out/bin/cursor"
      #!${stdenvNoCC.shell}
      open -na "$CURSOR_APP" --args "\$@"
      EOF
      chmod +x "$out/bin/cursor"
    ''}

    runHook postInstall
  '';

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [
      sarahec
      aspauldingcode
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "cursor";
  };
}

{ lib
, stdenvNoCC
, fetchurl
, appimageTools
, makeWrapper
}:
let
  pname = "cursor";
  version = "1.7.28";

  source = fetchurl {
    url = "https://downloads.cursor.com/production/adb0f9e3e4f184bba7f3fa6dbfd72ad0ebb8cfd8/linux/x64/Cursor-1.7.28-x86_64.AppImage";
    hash = "sha256-ZB/xGGKyVnfmNASWtfkmoxvzzkXa2pUlmgY2Bb9f5lU=";
  };

  wrappedAppimage = appimageTools.wrapType2 {
    inherit version pname;
    src = source;
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = wrappedAppimage;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/

    cp -r bin $out/bin

    # wayland fixes
    wrapProgram $out/bin/cursor \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update"

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
    platforms = lib.platforms.linux;
    mainProgram = "cursor";
  };
}

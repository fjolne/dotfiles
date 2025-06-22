{ lib
, stdenvNoCC
, fetchurl
, appimageTools
, makeWrapper
}:
let
  pname = "cursor";
  version = "1.1.3";

  source = fetchurl {
    url = "https://downloads.cursor.com/production/979ba33804ac150108481c14e0b5cb970bda3266/linux/x64/Cursor-1.1.3-x86_64.AppImage";
    hash = "sha256-mOwWNbKKykMaLFxfjaoGGrxfyhLX++fqJ0TXQtKVD8c=";
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

{ lib
, stdenvNoCC
, fetchurl
, appimageTools
, makeWrapper
}:
let
  pname = "cursor";
  version = "2.2.14";

  source = fetchurl {
    url = "https://downloads.cursor.com/production/1685afce45886aa5579025ac7e077fc3d4369c52/linux/x64/Cursor-2.2.14-x86_64.AppImage";
    hash = "sha256-L4kzRm08rWbb05VNX5RHyPaL3Ij6UCzQDoLaahIGYbI=";
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

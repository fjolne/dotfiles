{ pkgs }:
let
  inherit (pkgs) lib stdenv stdenvNoCC;
in
{
  # Claude desktop app: repackaged from Anthropic's apt repo (Debian/Ubuntu only
  # upstream, see https://code.claude.com/docs/en/desktop-linux). Bundles its own
  # Electron, so we just patchelf the shipped binaries against nixpkgs libs.
  claude-desktop = stdenv.mkDerivation (finalAttrs: {
    pname = "claude-desktop";
    version = "1.24012.9";

    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
      hash = "sha256-MC5tII3YyOnlIGfaoo7zsRcaFhNYb9DhC+3GQiJbbuE=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      makeWrapper
      wrapGAppsHook3
    ];

    # We wrap the launcher by hand below so the GApps env lands on it.
    dontWrapGApps = true;

    buildInputs = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libcap_ng # virtiofsd (Cowork VM)
      libdrm
      libgbm
      libseccomp # virtiofsd (Cowork VM)
      libsecret
      libxkbcommon
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      systemd # libudev
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXtst
      xorg.libxcb
    ];

    # Dlopen'ed at runtime rather than linked, so autoPatchelf can't see them.
    runtimeDependencies = with pkgs; [
      libglvnd
      libnotify
      vulkan-loader
    ];

    # chrome-sandbox is setuid, which the build sandbox refuses to reproduce —
    # skip it. Electron falls back to the user-namespace sandbox, which NixOS
    # allows.
    unpackPhase = ''
      runHook preUnpack

      dpkg-deb --fsys-tarfile $src \
        | tar -x --no-same-owner --no-same-permissions \
              --exclude=./usr/lib/claude-desktop/chrome-sandbox

      runHook postUnpack
    '';
    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib $out/bin
      cp -r usr/lib/claude-desktop $out/lib/claude-desktop
      cp -r usr/share $out/share

      makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [ libglvnd vulkan-loader ])}

      runHook postInstall
    '';

    meta = {
      description = "Claude desktop app (Chat, Cowork, and Claude Code)";
      homepage = "https://claude.ai/download";
      license = lib.licenses.unfree;
      mainProgram = "claude-desktop";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  });

  # ChatGPT desktop app, including its Codex workspace, repackaged from
  # OpenAI's Debian repository. The Linux preview does not officially support
  # NixOS, so patch the bundled Electron binaries against nixpkgs libraries.
  chatgpt-desktop = stdenv.mkDerivation (finalAttrs: {
    pname = "chatgpt-desktop";
    version = "26.814.41957";

    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${finalAttrs.version}_amd64.deb";
      hash = "sha256-R3iyanq9CGRyFNWwXBe9Pr4tlojRRtq/AXwaL6+TrH0=";
    };

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      makeWrapper
      wrapGAppsHook3
    ];

    # We wrap the launcher by hand below so the GApps env lands on it.
    dontWrapGApps = true;

    buildInputs = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libusb1
      libxkbcommon
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      systemd # libudev
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
    ];

    # Dlopen'ed at runtime rather than linked, so autoPatchelf can't see them.
    runtimeDependencies = with pkgs; [
      libglvnd
      libnotify
      libsecret
      vulkan-loader
    ];

    # The Debian package ships optional Qt integration shims and musl variants
    # next to the glibc native modules, without depending on Qt or musl.
    autoPatchelfIgnoreMissingDeps = [
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libc.musl-x86_64.so.1"
    ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb --fsys-tarfile $src \
        | tar -x --no-same-owner --no-same-permissions

      runHook postUnpack
    '';
    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib $out/bin
      cp -r usr/lib/chatgpt $out/lib/chatgpt
      cp -r usr/share $out/share

      makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
        "''${gappsWrapperArgs[@]}" \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [ git xdg-utils ])} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [ libglvnd vulkan-loader ])}

      runHook postInstall
    '';

    meta = {
      description = "ChatGPT desktop app with Codex";
      homepage = "https://developers.openai.com/codex/app";
      license = lib.licenses.unfree;
      mainProgram = "chatgpt";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  });

  codex-bin = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "codex-bin";
    version = "0.131.0-alpha.22";

    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-1s78xOlef+nI7Ar2vTxBXPH7+GwlnJE6uVzwRdxPCyw=";
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex

      runHook postInstall
    '';

    meta = {
      description = "OpenAI Codex CLI";
      homepage = "https://github.com/openai/codex";
      license = lib.licenses.asl20;
      mainProgram = "codex";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  });
}

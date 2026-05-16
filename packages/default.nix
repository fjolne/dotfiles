{ pkgs }:
let
  inherit (pkgs) lib stdenvNoCC;
in
{
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

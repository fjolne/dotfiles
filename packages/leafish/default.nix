{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, openssl
, glib
, pango
, gdk-pixbuf
, atk
, gtk3
, pkg-config
, cmake
}:

rustPlatform.buildRustPackage rec {
  pname = "Leafish";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Lea-fish";
    repo = pname;
    rev = "dd283d3ce841c000c348a6b7b18a447cfbcc83e0";
    hash = "sha256-iNwlaejVfa2WJVuqSU3sqBpxBv+uDLWYIYBT5Vd4/+k=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "bevy_derive-0.5.0" = "sha256-2fFMp+ReTqVvRNUJYjx1L7E8bFOs44ow6PQZZt4a87c=";
    };
  };

  buildInputs = [ openssl ]
    ++ lib.optionals stdenv.isLinux [ glib pango gdk-pixbuf atk gtk3 ];
  nativeBuildInputs = [ pkg-config cmake ];

  meta = with lib; {
    description = "Open source Minecraft client written in Rust";
    homepage = "https://github.com/Lea-fish/Leafish";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ fjolne ];
  };
}

{ lib
, rustPlatform
, fetchFromGitHub
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage {
  pname = "bws";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "sdk";
    rev = "572def0736595288cfacba87165ac7ce25b1fc35";
    hash = "sha256-b6hpPpeRrlqiEl9oZLHMeytxZi7/u00la+O0Gylvibc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  buildAndTestSubdir = "crates/bws";

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Bitwarden Secrets Manager";
    homepage = "https://github.com/bitwarden/sdk";
    license = with licenses; [ free ];
    maintainers = with maintainers; [ fjolne ];
  };
}

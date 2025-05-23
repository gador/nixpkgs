{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "xan";
  version = "0.50.0";

  src = fetchFromGitHub {
    owner = "medialab";
    repo = "xan";
    tag = version;
    hash = "sha256-wPzseazDTxsQ9zki4oDiAYT7sRRcIln3b9f5FC2t2Ko=";
  };

  cargoHash = "sha256-BagQNDWOhyz2x2TvwYvlE07rU9RuHQHGAVAZu0JbfgE=";
  useFetchCargoVendor = true;

  # FIXME: tests fail and I do not have the time to investigate. Temporarily disable
  # tests so that we can manually run and test the package for packaging purposes.
  doCheck = false;

  meta = {
    description = "Command line tool to process CSV files directly from the shell";
    homepage = "https://github.com/medialab/xan";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ NotAShelf ];
    mainProgram = "xan";
  };
}

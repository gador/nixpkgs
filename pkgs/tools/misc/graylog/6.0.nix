{ callPackage, lib, ...}:
let
  buildGraylog = callPackage ./graylog.nix {};
in buildGraylog {
  version = "6.0.2";
  sha256 = "sha256-yxhT2YfloC3u/DX9hbAcO31DfDwhNfiuz/AgTABnNVg=";
  maintainers = [ lib.maintainers.f2k1de ];
  license = lib.licenses.sspl;
}

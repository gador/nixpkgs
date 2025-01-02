{
  lib,
  stdenv,
  callPackage,
}:

callPackage ../particl-core/package.nix { withGui = true; }

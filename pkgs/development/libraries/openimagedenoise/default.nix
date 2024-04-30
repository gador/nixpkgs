{
  appleMetalSupport ? false,
  cmake,
  config,
  cudaPackages,
  cudaSupport ? config.cudaSupport,
  darwin,
  fetchzip,
  ispc,
  lib,
  python3,
  stdenv,
  tbb,
  xcodebuild,
}:

# PLEASE NOTE:
# This will currently not build with appkeMetalSupport, because the required SDK needs to be at least 12
# which isn't available in nixpkgs, yet. Once it is available, the stdenv can be changed to a higher SDK
# version and it should (hopefully) compile with metal support.
# see https://github.com/NixOS/nixpkgs/pull/229210

let
  stdenv' = if stdenv.isDarwin then darwin.apple_sdk_11_0.stdenv else stdenv;
in
stdenv'.mkDerivation rec {
  pname = "openimagedenoise";
  version = "2.2.2";

  # The release tarballs include pretrained weights, which would otherwise need to be fetched with git-lfs
  src = fetchzip {
    url = "https://github.com/OpenImageDenoise/oidn/releases/download/v${version}/oidn-${version}.src.tar.gz";
    sha256 = "sha256-ZIrs4oEb+PzdMh2x2BUFXKyu/HBlFb3CJX24ciEHy3Q=";
  };

  patches = lib.optional cudaSupport ./cuda.patch;

  # metal support depends on the "metal" framework from xcode, which isn't packed in the apple sdks in nixpkgs
  postPatch =
    ''
      substituteInPlace devices/metal/CMakeLists.txt \
        --replace-fail "AppleClang" "Clang"
    ''
    + lib.optionalString (appleMetalSupport) ''
      substituteInPlace cmake/oidn_metal.cmake \
        --replace-fail "xcrun -sdk macosx metal" "${darwin.xcode_14}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/metal"
    '';

  # fixcmake will repace the sub-path "/usr/" above to "/var/empty"
  dontFixCmake = appleMetalSupport;

  nativeBuildInputs = [
      cmake
      python3
      ispc
    ] ++ lib.optional cudaSupport cudaPackages.cuda_nvcc
    ++ lib.optionals stdenv.isDarwin [ xcodebuild ]
    ++ lib.optionals appleMetalSupport [ darwin.xcode_14 ];

  buildInputs =
    [ tbb ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk_11_0.frameworks;
      [
        Accelerate
        MetalKit
        MetalPerformanceShadersGraph
      ]
    )
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cccl
    ];

  cmakeFlags = [
    (lib.cmakeBool "OIDN_DEVICE_CUDA" cudaSupport)
    (lib.cmakeBool "OIDN_DEVICE_METAL" appleMetalSupport)
    (lib.cmakeFeature "TBB_INCLUDE_DIR" "${tbb.dev}/include")
    (lib.cmakeFeature "TBB_ROOT" "${tbb}")
  ];

  meta = with lib; {
    homepage = "https://openimagedenoise.github.io";
    description = "High-Performance Denoising Library for Ray Tracing";
    license = licenses.asl20;
    maintainers = [ maintainers.leshainc ];
    platforms = platforms.unix;
    changelog = "https://github.com/OpenImageDenoise/oidn/blob/v${version}/CHANGELOG.md";
  };
}

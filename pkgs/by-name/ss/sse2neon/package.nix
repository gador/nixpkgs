{ lib
, fetchFromGitHub
, pkg-config
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "sse2neon";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "DLTcollab";
    repo = "sse2neon";
    rev = "v${version}";
    hash = "sha256-riFFGIA0H7e5StYSjO0/JDrduzfwS+lOASzk5BRUyo4=";
  };

  postPatch = ''
    # remove warning about gcc < 10
    substituteInPlace sse2neon.h --replace-fail "#warning \"GCC versions" "// "
  '';

  outputs = [ "out" ];


  nativeBuildInputs = [
    pkg-config
  ];

  dontInstall = true;
  dontFixup = true;
  postBuild = ''
    mkdir -p $out/lib
    install -m444 sse2neon.h $out/lib/
  '';

  meta = with lib; {
    description = "A C/C++ header file that converts Intel SSE intrinsics to Arm/Aarch64 NEON intrinsics.";
    homepage = "https://github.com/DLTcollab/sse2neon";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ gador ];
  };
}

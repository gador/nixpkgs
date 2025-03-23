{
  lib,
  rel,
  buildKodiBinaryAddon,
  fetchFromGitHub,
  tinyxml-2,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "pvr-nextpvr";
  namespace = "pvr.nextpvr";
  version = "21.3.2";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.nextpvr";
    rev = "${version}-${rel}";
    sha256 = "sha256-SdnllQ32NaxdklE8h2Edo3Kh2QS/v7qOU3ckuVC+t9c=";
  };

  extraBuildInputs = [
    tinyxml-2
    zlib
  ];

  meta = with lib; {
    homepage = "https://github.com/kodi-pvr/pvr.nextpvr";
    description = "NextPVR PVR client addon for Kodi";
    platforms = platforms.all;
    license = licenses.gpl2Plus;
    maintainers = teams.kodi.members;
  };
}

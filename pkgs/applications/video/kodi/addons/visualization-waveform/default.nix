{ lib, rel, buildKodiBinaryAddon, fetchFromGitHub, pkgconfig, glm, libGL }:

buildKodiBinaryAddon rec {
  pname = "visualization-waveform";
  namespace = "visualization.waveform";
  version = "19.0.2";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "visualization.waveform";
    rev = "${version}-${rel}";
    hash = "sha256-IQLW4CDNtt/ptE679hnoXbharq61Ru9S2m7QbJLtNSI=";
  };

  extraBuildInputs = [ pkgconfig libGL ];

  propagatedBuildInputs = [ glm ];


  meta = with lib; {
    homepage = "https://github.com/xbmc/visualization.waveform";
    description = "Waveform visualization for kodi";
    platforms = platforms.all;
    license = licenses.gpl2Only;
    maintainers = teams.kodi.members;
  };
}

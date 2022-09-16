{ lib, rel, buildKodiBinaryAddon, fetchFromGitHub, pkgconfig, glm, libGL }:

buildKodiBinaryAddon rec {
  pname = "visualization-matrix";
  namespace = "visualization.matrix";
  version = "19.0.1";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = namespace;
    rev = "${version}-${rel}";
    hash = "sha256-w/2ZBcdtQ8/jXe9ucvAHqIS47TjotGo8bYWhP2Oux/0=";
  };

  extraBuildInputs = [ pkgconfig libGL ];

  propagatedBuildInputs = [ glm ];


  meta = with lib; {
    homepage = "https://github.com/xbmc/visualization.matrix";
    description = "Matrix visualization for kodi";
    platforms = platforms.all;
    license = licenses.gpl2Only;
    maintainers = teams.kodi.members;
  };
}

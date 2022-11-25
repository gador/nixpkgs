{ stdenv
, fetchurl
, lib
}:


stdenv.mkDerivation rec {
  pname = "git-remote-gitopia";
  version = "1.3.1";

  # source is also at https://gitopia.com/Gitopia/git-remote-gitopia but cannot be fetched without this helper
  src = fetchurl {
    url = "https://server.gitopia.com/releases/gitopia/git-remote-gitopia/v${version}/git-remote-gitopia_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-xU/P91rqP4cPwJIp8f8G3lwv1R1J2IZfh71929m1AHk=";
  };

  unpackPhase = ''
    tar xzf $src
  '';

  # packages are statically linked, so no patchElf necessary
  installPhase = ''
    mkdir -p $out/bin
    cp git-gitopia $out/bin
    cp git-remote-gitopia $out/bin
  '';


  meta = with lib; {
    description = "Git remote helper for gitopia";
    homepage = "https://gitopia.com/Gitopia/git-remote-gitopia";
    license = licenses.mit;
    maintainers = with maintainers; [ gador ];
  };
}

{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  db48,
  fetchFromGitHub,
  fetchpatch2,
  libevent,
  miniupnpc,
  openssl,
  pkg-config,
  zeromq,
  zlib,
  unixtools,
  python3,
  libsForQt5,
  qrencode,
  withGui ? false,
}:

stdenv.mkDerivation rec {
  pname = "particl-core";
  version = "23.2.7.0";

  src = fetchFromGitHub {
    owner = "particl";
    repo = "particl-core";
    rev = "v${version}";
    hash = "sha256-RxkLt+7u+r5jNwEWiArTUpZ8ykYwWtvIDFXTSKhGN/w=";
  };

  patches = [
    # upnp: fix build with miniupnpc 2.2.8
    (fetchpatch2 {
      url = "https://github.com/bitcoin/bitcoin/commit/8acdf66540834b9f9cf28f16d389e8b6a48516d5.patch?full_index=1";
      hash = "sha256-oDvHUvwAEp0LJCf6QBESn38Bu359TcPpLhvuLX3sm6M=";
    })
  ];

  # postPatch = ''
  #   substituteInPlace build-aux/m4/bitcoin_qt4.m4 --replace-fail "lrelease], $qt_bin_path" "lrelease], ${libsForQt5.qttools.dev}/bin"
  # '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ] ++ lib.optionals withGui [ libsForQt5.wrapQtAppsHook ];
  buildInputs =
    [
      openssl
      db48
      boost
      zlib
      miniupnpc
      libevent
      zeromq
      unixtools.hexdump
      python3
    ]
    ++ lib.optionals withGui [
      qrencode
      libsForQt5.qtbase
      libsForQt5.qttools
    ];
  configureFlags =
    [
      "--disable-bench"
      "--with-boost-libdir=${boost.out}/lib"
    ]
    ++ lib.optionals (!doCheck) [
      "--enable-tests=no"
    ]
    ++ lib.optionals withGui [
      "--with-gui=qt5"
      "--with-qt-bindir=${libsForQt5.qtbase.dev}/bin:${libsForQt5.qttools.dev}/bin"
    ];

  checkFlags =
    # QT_PLUGIN_PATH needs to be set when executing QT, which is needed when testing Bitcoin's GUI.
    # See also https://github.com/NixOS/nixpkgs/issues/24256
    lib.optional withGui "QT_PLUGIN_PATH=${libsForQt5.qtbase}/${libsForQt5.qtbase.qtPluginPrefix}";

  # Always check during Hydra builds
  doCheck = true;
  preCheck = "patchShebangs test";
  enableParallelBuilding = true;

  meta = with lib; {
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
    description = "Privacy-Focused Marketplace & Decentralized Application Platform";
    longDescription = ''
      An open source, decentralized privacy platform built for global person to person eCommerce.
      RPC daemon and CLI client only.
    '';
    homepage = "https://particl.io/";
    maintainers = with maintainers; [ demyanrogozhin ];
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

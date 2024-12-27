{
  cacert,
  cmake,
  cctools,
  curl,
  electron,
  fetchFromGitHub,
  fetchYarnDeps,
  lib,
  makeWrapper,
  nodejs,
  node-gyp,
  particl-core,
  pkg-config,
  stdenv,
  substituteAll,
  sqlite,
  vips,
  xcbuild,
  yarnConfigHook,
  yarnBuildHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "particl-desktop";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "particl";
    repo = "particl-desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MOYEt5UQy7PKAO2jEItHFQhq9iZzYfugnyWsalP0tYg=";
  };

  patches = [
    (substituteAll {
      src = ./fix_path.patch;
      particl_core = lib.getBin particl-core;
    })
  ];

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-zDlhnAuJQVrI+A7dO5hiGRTo15YnNuDBKWGJ3hyxdzA=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    node-gyp
    pkg-config
    nodejs
    makeWrapper
    (nodejs.python.withPackages (ps: [ ps.setuptools ]))
  ];

  dontUseCmakeConfigure = true;

  buildInputs =
    [
      vips
      sqlite
    ]
    # building sharp, zeromq and others from source on darwin
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      xcbuild
      cctools
      cacert
      cmake
      curl
    ];

  # generate .node binaries
  preBuild = ''
    npm rebuild --verbose --offline --nodedir=${nodejs} --sqlite=${lib.getDev sqlite} sharp
    npm rebuild --verbose --offline --nodedir=${nodejs} --sqlite=${lib.getDev sqlite} zeromq
  '';

  # https://stackoverflow.com/questions/69394632/webpack-build-failing-with-err-ossl-evp-unsupported
  env.NODE_OPTIONS = "--openssl-legacy-provider";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  yarnBuildScript = "build:electron:prod";

  # install only the necessary files
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/particl-desktop
    cp -r dist $out/lib/node_modules/particl-desktop/
    cp *.js $out/lib/node_modules/particl-desktop/
    cp -r modules $out/lib/node_modules/particl-desktop/
    cp package.json $out/lib/node_modules/particl-desktop/
    cp yarn.lock $out/lib/node_modules/particl-desktop/
    cp -r node_modules $out/lib/node_modules/particl-desktop/
    cp -r resources $out/lib/node_modules/particl-desktop/

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/particl-desktop \
      --add-flags $out/lib/node_modules/particl-desktop/main.js \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  dontStrip = true;

  meta = {
    description = "GUI application for Particl Markeplace and PART coin wallet";
    homepage = "https://particl.io";
    license = lib.licenses.gpl2Only;
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    maintainers = with lib.maintainers; [ gador ];
    mainProgram = "particl-desktop";
  };
})

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
  pkg-config,
  stdenv,
  sqlite,
  vips,
  xcbuild,
  yarnConfigHook,
  yarnBuildHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chlorio";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "nerdvibe";
    repo = "clorio-client";
    rev = "v${finalAttrs.version}";
    hash = "sha256-L8HPynm1ZRV/IQaGOmVzANHqDDhzeJDue9klb0dcLfU=";
  };

  postPatch = ''
    substituteInPlace package.json --replace-fail "pyarn" "yarn"
  '';

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-9g2SQMvRvA6hnhQtE+eYLRQRfpqTbQv6dQLkc44RMJY=";
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

  preBuild = ''
    ELECTRON_RUN_AS_NODE=1 NODE_OPTIONS= ${electron}/bin/electron scripts/update-electron-vendors.mjs
    npm rebuild --verbose --offline --nodedir=${nodejs} --sqlite=${lib.getDev sqlite} usb
    npm rebuild --verbose --offline --nodedir=${nodejs} --sqlite=${lib.getDev sqlite} node-hid
  '';

  # https://stackoverflow.com/questions/69394632/webpack-build-failing-with-err-ossl-evp-unsupported
  env.NODE_OPTIONS = "--openssl-legacy-provider";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  # yarnBuildScript = "compile";

  # install only the necessary files
  postBuild = ''
    cp -R ${electron.dist}/Electron.app Electron.app
    chmod -R u+w Electron.app
    MODE=production
    CSC_IDENTITY_AUTO_DISCOVERY=false
    yarn --offline run electron-builder build --config .electron-builder.config.cjs \
      --dir --config.asar=false \
      -c.npmRebuild="false" \
      -c.electronDist="." \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/
    mv "dist/mac-arm64/Clorio Wallet.app" $out/Applications/
    makeWrapper $out/Applications/Clorio\ Wallet.app/Contents/MacOS/Clorio\ Wallet $out/bin/clorio-wallet


    # mkdir -p $out/lib/node_modules/chlorio-client
    # # cp -r dist $out/lib/node_modules/particl-desktop/
    # cp *.js $out/lib/node_modules/chlorio-client/
    # cp  -r public $out/lib/node_modules/chlorio-client/
    # cp package.json $out/lib/node_modules/chlorio-client/
    # cp yarn.lock $out/lib/node_modules/chlorio-client/
    # cp -r node_modules $out/lib/node_modules/chlorio-client/
    # cp -r packages $out/lib/node_modules/chlorio-client/

    runHook postInstall
  '';

  # postInstall = ''
  #   makeWrapper ${electron}/bin/electron $out/bin/chlorio \
  #     --add-flags $out/lib/node_modules/chlorio-client/main.js \
  #     --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  # '';

  dontStrip = true;

  meta = {
    description = "Mina Protocol Wallet";
    homepage = "https://clor.io/";
    license = lib.licenses.asl20;
    platforms = [
      "aarch64-darwin"
      # "x86_64-linux"
    ];
    maintainers = with lib.maintainers; [ gador ];
    # mainProgram = "particl-desktop";
  };
})

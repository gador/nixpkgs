{
  lib,
  fetchFromGitea,
  yarn,
  nodejs,
  fixup-yarn-lock,
  fetchYarnDeps,
  buildGoModule,
}:
let
  mainVersion = "3.5";
  mainSrc = fetchFromGitea {
    domain = "projects.blender.org";
    owner = "studio";
    repo = "flamenco";
    rev = "v${mainVersion}";
    hash = "sha256-iAMQv4GzxS5PPQPrLCjBj7qd2HpAg91/BtMRoGTuJ5U=";
  };
  mainVendorHash = "sha256-DJooc+rGQ61lxjqP5+5eyQe7x69R3ADOwHDMu6NbICQ=";
in
buildGoModule rec {
  pname = "flamenco";
  version = mainVersion;
  src = mainSrc;
  vendorHash = mainVendorHash;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/web/app/yarn.lock";
    hash = "sha256-QcfyiL2/ALkxZpJyiwyD7xNlkOCPu4THCyywwZ40H8s=";
  };
  nativeBuildInputs = [
    fixup-yarn-lock
    nodejs
    yarn
  ];

  # by default, flamenco-manager will write to a directory right next to the executable
  # since this is not possible in nix, it will cause an error. This patch forces flamenco-manager
  # to use its current working directory (which is already used for its configuration)
  # see https://projects.blender.org/studio/flamenco/issues/102229#issuecomment-861219
  patches = [ ./fix-storage.patch ];

  only-addon-builder = buildGoModule {
    pname = "addon-packer";
    version = mainVersion;
    src = mainSrc;
    vendorHash = mainVendorHash;
    subPackages = [ "cmd/addon-packer" ];
  };

  ldflags = [
    "-X  projects.blender.org/studio/flamenco/internal/appinfo.ApplicationVersion=${version}"
    "-X  projects.blender.org/studio/flamenco/internal/appinfo.ReleaseCycle=release"
  ];

  excludedPackages = [
    "update-version"
    "addon-packer"
  ];

  preConfigure = ''
    export HOME="$TMPDIR"
    yarn config --offline set yarn-offline-mirror "$offlineCache"
    fixup-yarn-lock web/app/yarn.lock
    yarn --cwd web/app install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs web/app/node_modules
    yarn --cwd web/app build --outDir ../static --base=/app/ --minify false
    # this packs the blender addon, so it can be downloaded from the webserver
    # it cannot be used in postInstall as go needs this file during the build for the webserver
    ${only-addon-builder}/bin/addon-packer -filename web/static/flamenco-addon.zip
  '';

  postInstall = ''
    # the executable needs to be above the directory as the static webfiles
    mkdir -p "$out/share/flamenco/web"
    cp -r web/static $out/share/flamenco/web/
    mv $out/bin/flamenco-manager $out/share/flamenco/web
    ln -s $out/share/flamenco/web/flamenco-manager $out/bin/flamenco-manager
  '';

  # skip Test fail which is caused by our patch
  checkFlags = [ "-skip=^TestNewNextToExe$|^TestNewNextToExe.noSubdir$" ];

  meta = {
    description = "A lightweight, cross-platform framework to dispatch and schedule rendering jobs for smaller teams, or individuals";
    homepage = "https://flamenco.blender.org";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ gador ];
  };
}

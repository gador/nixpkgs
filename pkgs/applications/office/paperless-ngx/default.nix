{ lib
, fetchFromGitHub
, nixosTests
, python3
, ghostscript
, imagemagick
, jbig2enc
, optipng
, pngquant
, qpdf
, tesseract4
, unpaper
, liberation_ttf
, pkgs
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      django = super.django_3;
      django-picklefield = super.django-picklefield.overrideAttrs (oldAttrs: {
        # Checks do not pass with django 3
        doInstallCheck = false;
      });
      # Incompatible with aioredis 2
      aioredis = super.aioredis.overridePythonAttrs (oldAttrs: rec {
        version = "1.3.1";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "0fi7jd5hlx8cnv1m97kv9hc4ih4l8v15wzkqwsp73is4n0qazy0m";
        };
      });
    };
  };

  path = lib.makeBinPath [ ghostscript imagemagick jbig2enc optipng pngquant qpdf tesseract4 unpaper ];
in
py.pkgs.pythonPackages.buildPythonApplication rec {
  pname = "paperless-ngx";
  version = "ngx-1.6.0-rc1";

  src = fetchFromGitHub {
    owner = "paperless-ngx";
    repo = pname;
    rev = version;
    sha256 = "WblWDC29NYK4nceKT6qcu/SUq7lbsT5cg6YYaWGbooQ=";
  };

  format = "other";

  # Make bind address configurable
  postPatch = ''
    substituteInPlace gunicorn.conf.py --replace "bind = '0.0.0.0:8000'" ""
  '';

  propagatedBuildInputs = with py.pkgs.pythonPackages; [
    aioredis
    arrow
    asgiref
    async-timeout
    attrs
    autobahn
    automat
    blessed
    certifi
    cffi
    channels-redis
    channels
    chardet
    click
    coloredlogs
    concurrent-log-handler
    constantly
    cryptography
    daphne
    dateparser
    django-cors-headers
    django-extensions
    django-filter
    django-picklefield
    django-q
    django
    djangorestframework
    filelock
    fuzzywuzzy
    gunicorn
    h11
    hiredis
    httptools
    humanfriendly
    hyperlink
    idna
    imap-tools
    img2pdf
    incremental
    inotify-simple
    inotifyrecursive
    joblib
    langdetect
    lxml
    msgpack
    numpy
    ocrmypdf
    pathvalidate
    pdfminer
    pikepdf
    pillow
    pluggy
    portalocker
    psycopg2
    pyasn1-modules
    pyasn1
    pycparser
    pyopenssl
    python-dateutil
    python-dotenv
    python-gnupg
    python-Levenshtein
    python_magic
    pytz
    pyyaml
    redis
    regex
    reportlab
    requests
    scikit-learn
    scipy
    service-identity
    six
    sortedcontainers
    sqlparse
    threadpoolctl
    tika
    tqdm
    twisted.extras.tls
    txaio
    tzlocal
    urllib3
    uvicorn
    uvloop
    watchdog
    watchgod
    wcwidth
    websockets
    whitenoise
    whoosh
    zope_interface
  ];

  doCheck = true;
  checkInputs = with py.pkgs.pythonPackages; [
    pytest
    pytest-cov
    pytest-django
    pytest-env
    pytest-sugar
    pytest-xdist
    factory_boy
  ];

  # The tests require:
  # - PATH with runtime binaries
  # - A temporary HOME directory for gnupg
  # - XDG_DATA_DIRS with test-specific fonts
  checkPhase = ''
    pushd src
    PATH="${path}:$PATH" HOME=$(mktemp -d) XDG_DATA_DIRS="${liberation_ttf}/share:$XDG_DATA_DIRS" pytest
    popd
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r . $out/lib/paperless-ng
    chmod +x $out/lib/paperless-ng/src/manage.py
    makeWrapper $out/lib/paperless-ng/src/manage.py $out/bin/paperless-ng \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --prefix PATH : "${path}"
  '';

  passthru = {
    # PYTHONPATH of all dependencies used by the package
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;
    inherit path;

    tests = import ../../../../nixos/tests/paperless-ng.nix {
      package = pkgs.paperless-ngx;
    };
  };

  meta = with lib; {
    description = "The continuation of paperless-ng: scan, index, and archive all of your physical documents";
    homepage = "https://paperless-ngx.readthedocs.io/en/latest/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ gador ];
  };
}

{
  nodejs,
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  poetry-core,
  # install_requires
  charset-normalizer,
  h2,
  onecache,
  # test dependencies
  asgiref,
  black,
  django,
  click,
  httpx,
  proxy-py,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-django,
  pytest-mock,
  pytest-sugar,
  pytest-timeout,
  uvicorn,
  httptools,
  typed-ast,
  uvloop,
  requests,
  aiohttp,
  aiodns,
  pytestCheckHook,
  stdenv,
}:

buildPythonPackage rec {
  pname = "aiosonic";
  version = "0.20.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "sonic182";
    repo = "aiosonic";
    rev = "refs/tags/${version}";
    hash = "sha256-RMkmmXUqzt9Nsx8N+f9Xdbgjt1nd5NuJHs9dzarx8IY=";
  };

  postPatch =
    ''
      substituteInPlace pytest.ini --replace-fail \
        "addopts = --black --cov=aiosonic --cov-report term --cov-report html --doctest-modules" \
        "addopts = --doctest-modules"
    ''
    # patch `localhost`. See https://github.com/NixOS/nix/issues/1238
    + lib.optionalString stdenv.isLinux ''
      substituteInPlace tests/test_aiosonic.py --replace-fail \
        "localhost" "127.0.0.1"
      substituteInPlace tests/conftest.py --replace-fail \
        "localhost" "127.0.0.1"
    '';

  build-system = [ poetry-core ];

  dependencies = [
    charset-normalizer
    onecache
    h2
  ];

  nativeCheckInputs = [
    aiohttp
    aiodns
    asgiref
    black
    django
    click
    httpx
    proxy-py
    pytest-aiohttp
    pytest-asyncio
    pytest-django
    pytest-mock
    pytest-sugar
    pytest-timeout
    uvicorn
    httptools
    typed-ast
    uvloop
    requests
    pytestCheckHook
    nodejs
  ];

  pythonImportsCheck = [ "aiosonic" ];

  disabledTests =
    [
      # `proxy` fails on darwin and linux to proxy. Probably a sandbox/network error
      "test_proxy_request"
    ]
    ++ lib.optionals stdenv.isLinux [
      # django's `live_server` uses `localhost` which isn't available in the build env
      "test_post_multipart_to_django"
    ];

  meta = {
    changelog = "https://github.com/sonic182/aiosonic/blob/${version}/CHANGELOG.md";
    description = "Very fast Python asyncio http client";
    license = lib.licenses.mit;
    homepage = "https://github.com/sonic182/aiosonic";
    maintainers = with lib.maintainers; [ geraldog ];
  };
}

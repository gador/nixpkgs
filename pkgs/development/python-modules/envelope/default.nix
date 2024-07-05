{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  jsonpickle,
  python-magic,
  python-gnupg,
  py3-validate-email,
  m2crypto,
  gnupg,
  pythonOlder,
  setuptools,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "envelope";
  version = "2.0.3";

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "CZ-NIC";
    repo = "envelope";
    rev = "refs/tags/${version}";
    hash = "sha256-vtM7ldYMtsCa9KmggRstrIY2CJ45hPdjgRvMmTOKgIg=";
  };

  build-system = [ setuptools ];

  dependencies = [
    jsonpickle
    python-magic
    python-gnupg
    py3-validate-email
    m2crypto
  ];

  propagatedBuildInputs = [ gnupg ];

  nativeCheckInputs = [
    pytestCheckHook
    gnupg
  ];

  pytestFlagsArray = [ "tests.py" ];

  # maybe fails due to network error or gnupg homedir or gnupg keys..
  disabledTests = [ "test_arbitrary_encrypt" ];

  pythonImportsCheck = [ "envelope" ];

  meta = {
    homepage = "https://github.com/CZ-NIC/envelope";
    description = "Quick layer over python-gnupg, M2Crypto, smtplib, magic and email handling packages";
    changelog = "https://github.com/CZ-NIC/envelope/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ gador ];
  };
}

{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "zipstream-ng";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "pR0Ps";
    repo = "zipstream-ng";
    rev = "v${version}";
    sha256 = "NTsnGCddGDUxdHbEoM2ew756psboex3sb6MkYKtaSjQ=";
  };

  pythonImportsCheck = [
    "zipstream"
  ];

  checkInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "A modern and easy to use streamable zip file generator. It can package and stream many files and folders on the fly without needing temporary files or excessive memory";
    homepage = "https://github.com/pR0Ps/zipstream-ng";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ gador ];
  };
}

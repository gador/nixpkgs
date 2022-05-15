{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "dpcontracts";
  # does not have any kind of versioning
  version = "45cb8542272c2ebe095c6efb97aa9407ddc8bf3c";
  format = "setuptools";
  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "deadpixi";
    repo = "contracts";
    rev = version;
    hash = "sha256-FygJPXo7lZ9tlfqY6KmPJ3PLIilMGLBr3013uj9hCEs=";
  };

  # package does not have any tests

  pythonImportsCheck = [ "dpcontracts" ];


  meta = with lib; {
    description = "Provides a collection of decorators that makes it easy to write software using contracts";
    homepage = "https://github.com/deadpixi/contracts";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ gador ];
  };
}

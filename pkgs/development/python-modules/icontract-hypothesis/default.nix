{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, pytestCheckHook
, hypothesis
, icontract
}:

buildPythonPackage rec {
  pname = "icontract-hypothesis";
  version = "1.1.7";
  format = "setuptools";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "mristin";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-059/ylP7H7Sr5OMsTc4SQOgKEvgmw2ezpASLSdjVkF0=";
  };

  propagatedBuildInputs = [
    hypothesis
    icontract
  ];

  checkInputs = [
    pytestCheckHook
  ];

  # some tests fail due to unknown reasons. See upstream bug report
  # https://github.com/mristin/icontract-hypothesis/issues/67
  disabledTestPaths = [
    "icontract_hypothesis/pyicontract_hypothesis/_test.py"
  ];

  disabledTests = [
    "TestForwardDeclarations"
    "test_sequence_int"
  ];

  pythonImportsCheck = [ "icontract_hypothesis" ];

  meta = with lib; {
    description = "Combines design-by-contract with automatic testing";
    homepage = "https://github.com/mristin/icontract-hypothesis";
    license = licenses.mit;
    maintainers = with maintainers; [ gador ];
  };
}

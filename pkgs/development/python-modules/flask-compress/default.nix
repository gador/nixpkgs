{ lib
, fetchPypi
, buildPythonPackage
, flask
, brotli
, pytestCheckHook
}:

buildPythonPackage rec {
  version = "1.10.1";
  pname = "Flask-Compress";

  src = fetchPypi {
    inherit pname version;
    sha256 = "28352387efbbe772cfb307570019f81957a13ff718d994a9125fa705efb73680";
  };

  postPatch = ''
    sed -i -e 's/use_scm_version=.*/version="${version}",/' setup.py
  '';

  propagatedBuildInputs = [ flask brotli ];

  checkInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [ "flask_compress " ];

  meta = with lib; {
    description = "Compress responses in your Flask app with gzip";
    homepage = "https://github.com/colour-science/flask-compress";
    license = licenses.mit;
    maintainers = with maintainers; [ gador ];
  };
}

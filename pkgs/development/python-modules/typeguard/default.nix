{ buildPythonPackage
, fetchPypi
, pythonOlder
, lib
, setuptools-scm
, pytestCheckHook
, typing-extensions
, sphinxHook
, sphinx-autodoc-typehints
, sphinx-rtd-theme
, glibcLocales
, mypy
}:

buildPythonPackage rec {
  pname = "typeguard";
  version = "3.0.2";
  disabled = pythonOlder "3.7";
  outputs = [ "out" "doc" ];
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/uUpf9so+Onvy4FCte4hngI3VQnNd+qdJwta+CY1jVo=";
  };

  nativeBuildInputs = [
    glibcLocales
    setuptools-scm
    sphinxHook
    sphinx-autodoc-typehints
    sphinx-rtd-theme
  ];

  LC_ALL = "en_US.utf-8";

  nativeCheckInputs = [ pytestCheckHook typing-extensions mypy ];

  meta = with lib; {
    description = "This library provides run-time type checking for functions defined with argument type annotations";
    homepage = "https://github.com/agronholm/typeguard";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

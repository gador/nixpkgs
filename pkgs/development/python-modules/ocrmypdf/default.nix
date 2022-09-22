{ lib
, buildPythonPackage
, coloredlogs
, fetchFromGitHub
, ghostscript
, img2pdf
, importlib-metadata
, importlib-resources
, jbig2enc
, pdfminer-six
, pikepdf
, pillow
, pluggy
, pngquant
, pytest-xdist
, pytestCheckHook
, pythonOlder
, python3Packages
, reportlab
, setuptools-scm
, setuptools-scm-git-archive
, substituteAll
, tesseract5
, tqdm
, unpaper
, installShellFiles
}:

buildPythonPackage rec {
  pname = "ocrmypdf";
  version = "14.0.0";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "ocrmypdf";
    repo = "OCRmyPDF";
    rev = "v${version}";
    # The content of .git_archival.txt is substituted upon tarball creation,
    # which creates indeterminism if master no longer points to the tag.
    # See https://github.com/ocrmypdf/OCRmyPDF/issues/841
    postFetch = ''
      rm "$out/.git_archival.txt"
    '';
    hash = "sha256-EhOYN1s9k8s9r633BMLfvUrlCOALeEaIvMFiMvmjJwA=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  patches = [
    (substituteAll {
      src = ./paths.patch;
      gs = "${lib.getBin ghostscript}/bin/gs";
      jbig2 = "${lib.getBin jbig2enc}/bin/jbig2";
      pngquant = "${lib.getBin pngquant}/bin/pngquant";
      tesseract = "${lib.getBin tesseract5}/bin/tesseract";
      unpaper = "${lib.getBin unpaper}/bin/unpaper";
    })
  ];

  nativeBuildInputs = [
    python3Packages.poetry-core
    setuptools-scm-git-archive
    setuptools-scm
    installShellFiles
  ];

  propagatedBuildInputs = [
    coloredlogs
    img2pdf
    pdfminer-six
    pikepdf
    pillow
    pluggy
    reportlab
    tqdm
  ] ++ (lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ]) ++ (lib.optionals (pythonOlder "3.9") [
    importlib-resources
  ]);

  checkInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "ocrmypdf"
  ];

  postInstall = ''
    installShellCompletion --cmd ocrmypdf \
      --bash misc/completion/ocrmypdf.bash \
      --fish misc/completion/ocrmypdf.fish
  '';

  meta = with lib; {
    homepage = "https://github.com/ocrmypdf/OCRmyPDF";
    description = "Adds an OCR text layer to scanned PDF files, allowing them to be searched";
    license = with licenses; [ mpl20 mit ];
    maintainers = with maintainers; [ kiwi dotlambda ];
    changelog = "https://github.com/ocrmypdf/OCRmyPDF/blob/${src.rev}/docs/release_notes.rst";
  };
}

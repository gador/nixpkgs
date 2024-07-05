{
  lib,
  buildPythonPackage,
  fetchPypi,
  dnspython,
  idna,
  filelock,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py3-validate-email";
  version = "1.0.5";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+TWkM2ZQRCMr8xDyr4CerewwDnEWEgVBjbzCGiMcRLs=";
  };

  # Don't download blacklist on install
  postPatch = ''
    substituteInPlace setup.py --replace-fail "BlacklistUpdater()._install()" ""
  '';

  # install blacklist manually
  postBuild = ''
    mkdir build/lib/validate_email/data
    cp ${./disposable_email_blocklist.conf} build/lib/validate_email/data/blacklist.txt
  '';
  
  build-system = [ setuptools ];

  dependencies = [
    dnspython
    idna
    filelock
  ];

  # needs internet access to download a blacklist. Also for initial import, so no ImportsCheck
  doCheck = false;

  meta = {
    homepage = "https://git.ksol.io/karolyi/py3-validate-email";
    description = "Email validator with regex, blacklisted domains and SMTP checking";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ gador ];
  };
}

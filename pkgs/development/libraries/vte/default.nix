{ stdenv
, lib
, fetchFromGitLab
, fetchpatch
, gettext
, pkg-config
, meson
, ninja
, gnome
, glib
, gtk3
, gtk4
, gtkVersion ? "3"
, gobject-introspection
, vala
, python3
, gi-docgen
, libxml2
, gnutls
, gperf
, pango
, pcre2
, cairo
, fribidi
, lz4
, icu
, systemd
, systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd
, fast-float
, nixosTests
, blackbox-terminal
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vte";
  version = "0.78.0";

  outputs = [ "out" "dev" ]
    ++ lib.optional (gtkVersion != null) "devdoc";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "vte";
    rev = finalAttrs.version;
    hash = "sha256-Ql4q30Q4OEyH63SMbpMVyT/ZySeH/5b+5vo+Xv2HGdQ=";
  };

  patches = [
    # VTE needs a small patch to work with musl:
    # https://gitlab.gnome.org/GNOME/vte/issues/72
    # Taken from https://git.alpinelinux.org/aports/tree/community/vte3
    (fetchpatch {
      name = "0001-Add-W_EXITCODE-macro-for-non-glibc-systems.patch";
      url = "https://git.alpinelinux.org/aports/plain/community/vte3/fix-W_EXITCODE.patch?id=4d35c076ce77bfac7655f60c4c3e4c86933ab7dd";
      hash = "sha256-FkVyhsM0mRUzZmS2Gh172oqwcfXv6PyD6IEgjBhy2uU=";
    })
    # build: Add missing includes
    # https://gitlab.gnome.org/GNOME/vte/-/issues/2824
    (fetchpatch {
      name = "0002-build-Add-missing-includes.patch";
      url = "https://gitlab.gnome.org/GNOME/vte/-/commit/c90b078ecf4382458a9af44d765d710eb46b0453.patch";
      hash = "sha256-S7SHYBq309DLDOBGTFmUTUpsICl3mgMDb2RpYxy+o64=";
    })
    # build: Add fast_float dependency
    # https://gitlab.gnome.org/GNOME/vte/-/issues/2823
    (fetchpatch {
      name = "0003-build-Add-fast_float-dependency.patch";
      url = "https://gitlab.gnome.org/GNOME/vte/-/commit/f6095fca4d1baf950817e7010e6f1e7c313b9e2e.patch";
      hash = "sha256-EL9PPiI5pDJOXf4Ck4nkRte/jHx/QWbxkjDFRSsp+so=";
    })
    (fetchpatch {
      name = "0003-widget-termprops-Use-fast_float.patch";
      url = "https://gitlab.gnome.org/GNOME/vte/-/commit/6c2761f51a0400772f443f12ea23a75576e195d3.patch";
      hash = "sha256-jjM9bhl8EhtylUIQ2nMSNX3ugnkZQP/2POvSUDW0LM0=";
    })
    (fetchpatch {
      name = "0003-build-Use-correct-path-to-include-fast_float.h.patch";
      url = "https://gitlab.gnome.org/GNOME/vte/-/commit/d09330585e648b5c9991dffab4a06d1f127bf916.patch";
      hash = "sha256-YGVXt2VojljYgTcmahQ2YEZGEysyUSwk+snQfoipJ+E=";
    })
    # tests: Remove excessive constexpr
    # https://gitlab.gnome.org/GNOME/vte/-/issues/2819
    (fetchpatch {
      name = "0004-tests-Remove-excessive-constrexpr.patch";
      url = "https://gitlab.gnome.org/GNOME/vte/-/commit/c8838779d5f8c0e03411cef9775cd8f5a10a6204.patch";
      hash = "sha256-zF+tDAzllhbts5pO4Uo2DgzPxVunNmf42jWOgWJO3MI=";
    })
  ];

  nativeBuildInputs = [
    gettext
    gobject-introspection
    gperf
    libxml2
    meson
    ninja
    pkg-config
    vala
    python3
    gi-docgen
  ];

  buildInputs = [
    cairo
    fribidi
    gnutls
    pango # duplicated with propagatedBuildInputs to support gtkVersion == null
    pcre2
    lz4
    icu
  ] ++ lib.optionals systemdSupport [
    systemd
  ] ++ lib.optionals stdenv.cc.isClang [
    fast-float
  ];

  # Required by vte-2.91.pc.
  propagatedBuildInputs = lib.optionals (gtkVersion != null) [
    (assert (gtkVersion == "3" || gtkVersion == "4");
    if gtkVersion == "3" then gtk3 else gtk4)
    glib
    pango
  ];

  mesonFlags = [
    "-Ddocs=true"
    (lib.mesonBool "gtk3" (gtkVersion == "3"))
    (lib.mesonBool "gtk4" (gtkVersion == "4"))
  ] ++ lib.optionals (!systemdSupport) [
    "-D_systemd=false"
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # -Bsymbolic-functions is not supported on darwin
    "-D_b_symbolic_functions=false"
  ];

  # error: argument unused during compilation: '-pie' [-Werror,-Wunused-command-line-argument]
  env.NIX_CFLAGS_COMPILE = toString (lib.optional stdenv.hostPlatform.isMusl "-Wno-unused-command-line-argument"
    ++ lib.optional stdenv.cc.isClang "-Wno-cast-function-type-strict");

  postPatch = ''
    patchShebangs perf/*
    patchShebangs src/parser-seq.py
    patchShebangs src/minifont-coverage.py
    patchShebangs src/modes.py
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "vte";
      versionPolicy = "odd-unstable";
    };
    tests = {
      inherit (nixosTests.terminal-emulators) gnome-terminal lxterminal mlterm roxterm sakura stupidterm terminator termite xfce4-terminal;
      blackbox-terminal = blackbox-terminal.override { sixelSupport = true; };
    };
  };

  meta = with lib; {
    homepage = "https://www.gnome.org/";
    description = "Library implementing a terminal emulator widget for GTK";
    longDescription = ''
      VTE is a library (libvte) implementing a terminal emulator widget for
      GTK, and a minimal sample application (vte) using that.  Vte is
      mainly used in gnome-terminal, but can also be used to embed a
      console/terminal in games, editors, IDEs, etc. VTE supports Unicode and
      character set conversion, as well as emulating any terminal known to
      the system's terminfo database.
    '';
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ astsmtl antono ] ++ teams.gnome.members;
    platforms = platforms.unix;
  };
})

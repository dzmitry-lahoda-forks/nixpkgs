{
  lib,
  stdenv,
  fetchFromGitLab,
  pkg-config,
  autoreconfHook,
  rake,
  boost,
  cmark,
  docbook_xsl,
  expat,
  fetchpatch2,
  file,
  flac,
  fmt,
  gettext,
  gmp,
  gtest,
  libdvdread,
  libebml,
  libiconv,
  libmatroska,
  libogg,
  libvorbis,
  libxslt,
  nlohmann_json,
  pugixml,
  qtbase,
  qtmultimedia,
  qtwayland,
  utf8cpp,
  xdg-utils,
  zlib,
  withGUI ? true,
  wrapQtAppsHook,
}:

let
  inherit (lib)
    enableFeature
    getDev
    getLib
    optionals
    optionalString
    ;

  phase = name: args: ''
    runHook pre${name}

    rake ${args}

    runHook post${name}
  '';

in
stdenv.mkDerivation rec {
  pname = "mkvtoolnix";
  version = "87.0";

  src = fetchFromGitLab {
    owner = "mbunkus";
    repo = "mkvtoolnix";
    rev = "release-${version}";
    hash = "sha256-UU57ZgH1sxCXspwfKXScw08aJYiv+k526U8q8N1tA+4=";
  };

  patches = [
    (fetchpatch2 {
      url = "https://gitlab.com/mbunkus/mkvtoolnix/-/commit/fc83003f541ac690fe308c3f4ac36e62814a40db.diff";
      hash = "sha256-HOS79g5xm70upV5Okv1COEg0SanXs7brRRB59Ofx5HA=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    gettext
    gtest
    libxslt
    pkg-config
    rake
  ] ++ optionals withGUI [ wrapQtAppsHook ];

  # qtbase and qtmultimedia are needed without the GUI
  buildInputs =
    [
      boost
      expat
      file
      flac
      fmt
      gmp
      libdvdread
      libebml
      libmatroska
      libogg
      libvorbis
      nlohmann_json
      pugixml
      qtbase
      qtmultimedia
      utf8cpp
      xdg-utils
      zlib
    ]
    ++ optionals withGUI [ cmark ]
    ++ optionals stdenv.hostPlatform.isLinux [ qtwayland ];

  # autoupdate is not needed but it silences a ton of pointless warnings
  postPatch = ''
    patchShebangs . > /dev/null
    autoupdate configure.ac ac/*.m4
  '';

  configureFlags = [
    "--disable-debug"
    "--disable-precompiled-headers"
    "--disable-profiling"
    "--disable-static-qt"
    "--disable-update-check"
    "--enable-optimization"
    "--with-boost-libdir=${getLib boost}/lib"
    "--with-docbook-xsl-root=${docbook_xsl}/share/xml/docbook-xsl"
    "--with-gettext"
    "--with-extra-includes=${getDev utf8cpp}/include/utf8cpp"
    "--with-extra-libs=${getLib utf8cpp}/lib"
    (enableFeature withGUI "gui")
  ];

  buildPhase = phase "Build" "";

  installPhase = phase "Install" "install";

  doCheck = true;

  checkPhase = phase "Check" "tests:run_unit";

  dontWrapQtApps = true;

  postFixup = optionalString withGUI ''
    wrapQtApp $out/bin/mkvtoolnix-gui
  '';

  meta = with lib; {
    description = "Cross-platform tools for Matroska";
    homepage = "https://mkvtoolnix.download/";
    license = licenses.gpl2Only;
    mainProgram = if withGUI then "mkvtoolnix-gui" else "mkvtoolnix";
    maintainers = with maintainers; [
      codyopel
      rnhmjoj
    ];
    platforms = platforms.unix;
  };
}

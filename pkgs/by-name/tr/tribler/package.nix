{
  lib,
  stdenv,
  fetchurl,
  fetchPypi,
  python311,
  makeWrapper,
  libtorrent-rasterbar-1_2_x,
  qt5,
  nix-update-script,
}:

let
  # libtorrent-rasterbar-1_2_x requires python311
  python3 = python311;
  libtorrent = (python3.pkgs.toPythonModule (libtorrent-rasterbar-1_2_x)).python;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tribler";
  version = "8.0.7";

  src = fetchurl {
    url = "https://github.com/Tribler/tribler/archive/refs/tags/v${finalAttrs.version}.tar.gz";
    hash = "sha256-FlIhQkWgY1Wv62EekkMBuYhjv3W3SmTttSasHnGWzx0=";
  };

  nativeBuildInputs = [
    python3.pkgs.wrapPython
    makeWrapper
    # we had a "copy" of this in tribler's makeWrapper
    # but it went out of date and broke, so please just use it directly
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ python3.pkgs.python ];

  pythonPath =
    [ libtorrent ]
    ++ (with python3.pkgs; [
      # requirements-core.txt
      aiohttp
      aiohttp-apispec
      anyio
      chardet
      configobj
      cryptography
      decorator
      faker
      libnacl
      lz4
      marshmallow
      netifaces
      networkx
      pony
      psutil
      pyasn1
      pydantic_1
      pyopenssl
      pyyaml
      sentry-sdk
      service-identity
      yappi
      yarl
      bitarray
      filelock
      (pyipv8.overrideAttrs (p: rec {
        version = "2.13.0";
        src = fetchPypi {
          inherit (p) pname;
          inherit version;
          hash = "sha256-Qp5vqMa7kfSp22C5KAUvut+4YbSXMEZRsHsLevB4QvE=";
        };
      }))
      file-read-backwards
      brotli
      human-readable
      # requirements.txt
      pillow
      pyqt5
      pyqt5-sip
      pyqtgraph
      pyqtwebengine
    ]);

  installPhase = ''
    mkdir -pv $out
    # Nasty hack; call wrapPythonPrograms to set program_PYTHONPATH.
    wrapPythonPrograms
    cp -prvd ./* $out/
    makeWrapper ${python3.pkgs.python}/bin/python $out/bin/tribler \
        --set _TRIBLERPATH "$out/src" \
        --set PYTHONPATH $out/src/tribler/core:$out/src/tribler/ui:$program_PYTHONPATH \
        --set NO_AT_BRIDGE 1 \
        --chdir "$out/src" \
        --add-flags "-O $out/src/run_tribler.py"

    mkdir -p $out/share/applications $out/share/icons
    cp $out/build/debian/tribler/usr/share/applications/org.tribler.Tribler.desktop $out/share/applications/
    cp $out/build/debian/tribler/usr/share/pixmaps/tribler_big.xpm $out/share/icons/tribler.xpm
    mkdir -p $out/share/copyright/tribler
    mv $out/LICENSE.txt $out/share/copyright/tribler
  '';

  shellHook = ''
    wrapPythonPrograms || true
    export QT_QPA_PLATFORM_PLUGIN_PATH=$(echo ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms)
    export PYTHONPATH=./tribler/core:./tribler/ui:$program_PYTHONPATH
    export QT_PLUGIN_PATH="${qt5.qtsvg.bin}/${qt5.qtbase.qtPluginPrefix}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Decentralised P2P filesharing client based on the Bittorrent protocol";
    mainProgram = "tribler";
    homepage = "https://www.tribler.org/";
    changelog = "https://github.com/Tribler/tribler/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [
      xvapx

      mkg20001
    ];
    platforms = lib.platforms.linux;
  };
})

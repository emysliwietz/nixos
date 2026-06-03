# iriunwebcam.nix — package derivation
# Place alongside iriunwebcam-module.nix in your flake's directory.

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, qt5
, avahi
, alsa-lib
, libdrm
}:

stdenv.mkDerivation rec {
  pname = "iriunwebcam";
  version = "2.9.1";

  src = fetchurl {
    url  = "https://iriun.gitlab.io/iriunwebcam-${version}.deb";
    hash = "sha256-slpTyetT96waR7XvcXSZDdl/Ziacc4hgM5XCxX8WC4Q=";
    # If the hash fails, re-derive it with:
    #   nix-prefetch-url https://iriun.gitlab.io/iriunwebcam-2.9.1.deb
  };

  # ── build-time tools ─────────────────────────────────────────────────────
  nativeBuildInputs = [
    autoPatchelfHook    # rewrites ELF interpreter + RPATHs to Nix store paths
    dpkg                # provides dpkg-deb for unpacking
    qt5.wrapQtAppsHook  # wraps the binary with QT_PLUGIN_PATH so xcb loads
  ];

  # ── runtime libraries ────────────────────────────────────────────────────
  # Direct NEEDED entries from readelf:
  #   libavahi-{client,common}  libasound  libdrm
  #   libQt5{Widgets,Gui,Network,Core}  libstdc++  libgcc_s
  # Everything else (libdbus, libGL, libX11, …) comes in transitively.
  buildInputs = [
    avahi             # libavahi-client.so.3, libavahi-common.so.3
    alsa-lib          # libasound.so.2
    libdrm            # libdrm.so.2
    qt5.qtbase        # libQt5{Widgets,Gui,Network,Core}.so.5
    stdenv.cc.cc.lib  # libstdc++.so.6, libgcc_s.so.1
  ];

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" "$out"

    # Relocate binary to $out/bin
    install -Dm755 "$out/usr/local/bin/iriunwebcam" "$out/bin/iriunwebcam"

    # Relocate desktop entry + icon to $out/share
    mkdir -p "$out/share"
    cp -r "$out/usr/share/." "$out/share/"

    # Patch the hardcoded Exec path in the .desktop file
    substituteInPlace "$out/share/applications/iriunwebcam.desktop" \
      --replace '/usr/local/bin/iriunwebcam' "$out/bin/iriunwebcam"

    rm -rf "$out/usr" "$out/etc"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Use your phone's camera as a wireless webcam on Linux";
    homepage    = "https://iriun.com";
    platforms   = [ "x86_64-linux" ];
    license     = licenses.unfree;
  };
}

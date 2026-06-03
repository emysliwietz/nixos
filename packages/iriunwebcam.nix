# iriunwebcam.nix — package derivation

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, zstd               # needed for tar to decompress data.tar.zst
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
  };

  nativeBuildInputs = [
    autoPatchelfHook    # rewrites ELF interpreter + RPATHs to Nix store paths
    zstd                # lets tar handle data.tar.zst
    qt5.wrapQtAppsHook  # sets QT_PLUGIN_PATH etc. so the xcb platform plugin loads
  ];

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

    # Extract the .deb manually instead of via dpkg-deb.
    # dpkg-deb can produce root-owned files that Nix's sandbox rejects with
    # "suspicious ownership or permission". ar + tar --no-same-owner forces
    # everything to be owned by the build user.
    ar x "$src"
    tar --no-same-owner --no-same-permissions \
        --zstd -xf data.tar.zst -C "$out"

    # Relocate binary to the standard $out/bin
    install -Dm755 "$out/usr/local/bin/iriunwebcam" "$out/bin/iriunwebcam"

    # Relocate desktop entry + icon to $out/share
    mkdir -p "$out/share"
    cp -r "$out/usr/share/." "$out/share/"

    # Fix the hardcoded Exec= path in the .desktop file
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

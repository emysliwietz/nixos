# artcraft-launcher.nix — package derivation (prebuilt release tarball)

{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, wayland
, libxkbcommon
, libGL
, vulkan-loader
, libx11
, libxcursor
, libxrandr
, libxi
, libxcb
, dbus
}:

stdenv.mkDerivation rec {
  pname = "artcraft-launcher";
  version = "0.7.0";

  src = fetchurl {
    url  = "https://github.com/storytold/craft-launcher/releases/download/v${version}/artcraft-launcher-${version}-linux-x86_64.tar.gz";
    hash = "sha256-0rQg2eCAVJgpraH0Tzw3NfzCC9GJNnArNqWY4txxOrk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook    # rewrites ELF interpreter + RPATHs to Nix store paths
  ];

  buildInputs = [
    stdenv.cc.cc.lib    # libgcc_s.so.1
  ];

  # The binary only links libc/libgcc; egui/winit dlopen() the windowing libs at
  # runtime, so add them to its RPATH (same list as upstream's flake.nix).
  runtimeDependencies = [
    wayland
    libxkbcommon
    libGL               # libEGL.so via libglvnd
    vulkan-loader
    libx11
    libxcursor
    libxrandr
    libxi
    libxcb
    dbus                # libdbus-1.so.3 (tray icon / notifications)
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/artcraft-launcher "$out/bin/artcraft-launcher"
    cp -r share "$out/share"

    substituteInPlace "$out/share/applications/ai.storyteller.artcraft-launcher.desktop" \
      --replace-fail 'TryExec=artcraft-launcher' "TryExec=$out/bin/artcraft-launcher" \
      --replace-fail 'Exec=artcraft-launcher'    "Exec=$out/bin/artcraft-launcher"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Installs, updates and launches the ArtCraft / Craft App Suite";
    homepage    = "https://github.com/storytold/craft-launcher";
    license     = with licenses; [ mit asl20 ];
    platforms   = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "artcraft-launcher";
  };
}

# ArtCraft Launcher — installs, updates and opens the Craft App Suite
# (PhotoCraft, FilmCraft, VectorCraft, …) — https://getartcraft.com/apps
{ pkgs, ... }:

let
  artcraft-launcher = pkgs.callPackage ./artcraft/package.nix {};
in
{
  environment.systemPackages = [ artcraft-launcher ];

  # NixOS has no apt/dnf, so the launcher installs each app as an AppImage in
  # ~/Applications and execs it directly. binfmt hands AppImages to appimage-run.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}

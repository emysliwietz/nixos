# iriunwebcam-module.nix — NixOS module
#
# Wire into your flake.nix like this:
#
#   nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
#     modules = [
#       ./configuration.nix
#       ./iriunwebcam-module.nix   # ← add this line
#     ];
#   };
#
# Then: nixos-rebuild switch --flake .#myhostname

{ config, lib, pkgs, ... }:

let
  iriunwebcam = pkgs.callPackage ./iriunwebcam.nix {};
in
{
  # ── Kernel modules ──────────────────────────────────────────────────────────
  # v4l2loopback: creates the virtual /dev/video* device Iriun streams into.
  # snd-aloop:    creates the ALSA loopback card for audio.
  boot.kernelModules       = [ "v4l2loopback" "snd-aloop" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  # Reproduces what the .deb's postinst did:
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 devices=1 \
      card_label="Iriun Webcam,Iriun Webcam #2,Iriun Webcam #3,Iriun Webcam #4"
    options snd-aloop enable=1 index=7
  '';

  # ── Packages ────────────────────────────────────────────────────────────────
  environment.systemPackages = [
    iriunwebcam
    pkgs.android-tools   # adb — needed for USB connection mode
  ];

  # ── Device access ────────────────────────────────────────────────────────────
  # Your user needs `video` (for /dev/video*) and `audio` (for ALSA loopback).
  # Either add this here:
  #   users.users."yourusername".extraGroups = [ "video" "audio" ];
  # Or add it wherever you already configure your user.
}

{ config, lib, pkgs, ... }:

{
  # Stream this screen to the Fire TV (Moonlight client): GPU-encoded, low latency.
  # Web UI / pairing: https://localhost:47990
  services.sunshine = {
    enable = true;
    autoStart = true;     # user service, starts with the graphical session
    capSysAdmin = true;   # allows KMS capture (lowest overhead) on Wayland
    openFirewall = true;  # TCP 47984/47989/47990/48010, UDP 47998-48000/48002/48010
  };

  # VAAPI driver for the Intel UHD 620, which does the encoding (the Quadro P500
  # has no NVENC). Without it Sunshine falls back to slow software x264.
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
}

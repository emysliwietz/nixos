{ config, lib, pkgs, ... }:

{
  boot = {
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 30;

    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [
      "snd-aloop"
    ];

  };
}

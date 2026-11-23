{ config, pkgs, ... }:

{
  # Tell Xorg/Wayland to use the nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Wayland
    modesetting.enable = true;

    # Power management — lets dGPU fully power off when idle
    powerManagement.enable = true;
    powerManagement.finegrained = true; # requires offload mode (set below)

    # Quadro P500 is Pascal — open modules require Turing+, so keep this false
    open = false;

    # Drivers after 580 dropped Pascal; the default one ignores the P500
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # Enables the nvidia-settings GUI
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # adds `nvidia-offload` helper command
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  # Enables D-Bus service that KDE Plasma uses for per-app GPU selection
  services.switcherooControl.enable = true;
}

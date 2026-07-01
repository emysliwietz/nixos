{ config, lib, pkgs, ... }:

{
  # Remove spectacle (KDE's default screenshot tool)
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    spectacle
  ];

  home-manager.users.user = {
    services.flameshot = {
      enable = true;
      settings.General = {
        showStartupLaunchMessage = false;
        useGrimAdapter = true;
      };
    };

    # Desktop file so KDE can bind a global shortcut to it
    xdg.desktopEntries.flameshot-screenshot = {
      name = "Flameshot Screenshot";
      exec = "flameshot gui";
      noDisplay = true;
      type = "Application";
    };
  };
}

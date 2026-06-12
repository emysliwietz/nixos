{ config, pkgs, ... }:

{
  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # Remove undesired packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    discover
    elisa
    okular
  ];

  # Add in non-default desired packages
  home-manager.users.user.home.packages = with pkgs.kdePackages; [
    # RDC/VNC Client
    krdc
  ];

  home-manager.users.user.programs.plasma = {
    enable = true;

    configFile.kdeglobals.General = {
      TerminalApplication = "kitty";
    };
  };

  programs.kdeconnect.enable = true;
}

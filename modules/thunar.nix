{ config, pkgs, ... }:

{
  programs.thunar.enable = true;

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  programs.xfconf.enable = true; # needed to keep thunar config changes without full xfce

  services.tumbler.enable = true; # Thumbnails in thunar
  services.gvfs.enable = true; # Mount, trash in thunar

  # File Conversion tools
  home-manager.users.user = {
    xdg.configFile."Thunar/uca.xml".source = ./thunar/uca.xml;
  };
}

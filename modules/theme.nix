{ config, lib, pkgs, ... }:

{
  home-manager.users.user = {
      home.packages = with pkgs; [
        kdePackages.breeze-gtk

        # Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
	    nerd-fonts.sauce-code-pro
        symbola
      ];

    gtk = {
      enable = true;
      theme = {
        package = pkgs.kdePackages.breeze-gtk;
        name = "Breeze-Dark";
      };

      font = {
        name = "SauceCodePro Semibold";
        size = 10;
      };

      cursorTheme = {
        name = "breeze_cursors";
        size = 24;
      };

      iconTheme = {
        package = pkgs.flat-remix-icon-theme;
        name = "Flat-Remix-Green-Dark";
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  }


}

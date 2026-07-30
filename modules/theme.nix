{ config, lib, pkgs, ... }:

let
  # Flat-Remix ships no `network-bluetooth-*-symbolic` icons, which is the exact
  # name Plasma 6's BlueDevil applet uses for the tray icon — so it fell back to a
  # folder. Alias those names to the theme's own bluetooth artwork and refresh the
  # GTK icon cache the package ships.
  flat-remix-icon-theme-bt = pkgs.flat-remix-icon-theme.overrideAttrs (old: {
    installPhase = (old.installPhase or "") + ''
      for theme in $out/share/icons/Flat-Remix-*; do
        sym="$theme/status/symbolic"
        if [ -e "$sym/bluetooth-active-symbolic.svg" ]; then
          ln -sf bluetooth-active-symbolic.svg   "$sym/network-bluetooth-symbolic.svg"
          ln -sf bluetooth-active-symbolic.svg   "$sym/network-bluetooth-activated-symbolic.svg"
          ln -sf bluetooth-disabled-symbolic.svg "$sym/network-bluetooth-inactive-symbolic.svg"
          gtk-update-icon-cache -f -q "$theme" || true
        fi
      done
    '';
  });
in
{
home-manager.users.user = {

      fonts.fontconfig.enable = true;

      # home.file.".gtkrc-2.0".force = lib.mkForce true;

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
	  package = flat-remix-icon-theme-bt;
          name = "Flat-Remix-Green-Dark";
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
	    nerd-fonts.sauce-code-pro
        symbola

];
};


}

{ config, lib, pkgs, ... }:

{
  home-manager.users.user = {
    programs.zathura = {
      enable = true;
      mappings = {
        i = "recolor";
        n = "navigate next";
        p = "navigate previous";
      };
      options = {
        selection-clipboard = "clipboard";
        recolor-keephue = "true";
        recolor = "true";
        guioptions = "";
        window-title-home-tilde = "true";
        statusbar-basename = "true";
        adjust-open = "best-fit";
        scroll-page-aware = "true";
      };
    };
  };
}

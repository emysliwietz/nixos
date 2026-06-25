{ config, lib, pkgs, ... }:

{
  home-manager.users.user = {

    programs.bash.enable = true;

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      shellIntegration.enableZshIntegration = true;

      keybindings = {
        "super+q" = "quit";
        "cmd+c" = "copy_to_clipboard";
        "cmd+v" = "paste_from_clipboard";
        "alt+c" = "copy_to_clipboard";
        "alt+v" = "paste_from_clipboard";
        "alt+ctrl+plus" = "change_font_size all +2.0";
        "alt+ctrl+minus" = "change_font_size all -2.0";
        "ctrl+kp_add" = "change_font_size all +2.0";
        "ctrl+kp_subtract" = "change_font_size all -2.0";
      };

      settings = {
        confirm_os_window_close = 0;
        copy_on_select = "yes";
        dynamic_background_opacity = 1;
        background_opacity = 0.8;
        enable_audio_bell = 0;
        # background_blur = 5;
      };

	  font = {
        name = "SauceCodePro Nerd Font";
	    size = 11;
	  };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Shell Prompt
    programs.starship = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;

      options = [
        "--cmd cd"
      ];
    };
    # Turn off zoxide warnings
    home.sessionVariables._ZO_DOCTOR = "0";
  };
}

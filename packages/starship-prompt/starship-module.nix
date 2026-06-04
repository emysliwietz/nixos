# starship-module.nix — Doom One Dark × Powerline
#
# A faithful port of the official Gruvbox Rainbow preset
# (https://starship.rs/presets/gruvbox-rainbow) recoloured with the
# Doom One Dark palette.
#
# Usage (home-manager):
#   imports = [ ./starship-module.nix ];
#
# Prerequisite: a Nerd Font installed and selected in your terminal.
#
# Prompt layout:
#   [orange: os·user] ▶ [yellow: dir] ▶ [teal: git] ▶ [navy: langs+nix]
#   ▶ [gray: docker·conda] ▶ [dark: time] ▶
#   ❯

{ lib, ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # ── Powerline format ─────────────────────────────────────────────────────
      #
      # Each [](fg:PREV bg:NEXT) is a Nerd Font powerline arrow () that
      # bridges the two adjacent pill colours.  lib.concatStrings avoids TOML
      # line-continuation syntax altogether.
      format = lib.concatStrings [
        # pill 1 — OS + user  (orange)
        "[](color_orange)"
        "$os"
        "$username"
        # arrow orange → yellow
        "[](bg:color_yellow fg:color_orange)"
        # pill 2 — directory  (yellow)
        "$directory"
        # arrow yellow → teal
        "[](fg:color_yellow bg:color_aqua)"
        # pill 3 — git  (teal)
        "$git_branch"
        "$git_status"
        # arrow teal → navy
        "[](fg:color_aqua bg:color_blue)"
        # pill 4 — language versions + nix-shell  (navy)
        "$c"
        "$cpp"
        "$rust"
        "$golang"
        "$nodejs"
        "$bun"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "$nix_shell"
        # arrow navy → dark-gray
        "[](fg:color_blue bg:color_bg3)"
        # pill 5 — docker / conda  (dark-gray)
        "$docker_context"
        "$conda"
        # arrow dark-gray → near-black
        "[](fg:color_bg3 bg:color_bg1)"
        # pill 6 — clock  (near-black)
        "$time"
        # closing arrow → terminal background
        "[ ](fg:color_bg1)"
        # second line
        "$line_break$character"
      ];

      # ── Doom One Dark palette ────────────────────────────────────────────────
      palette = "doom_one_dark";

      palettes.doom_one_dark = {
        color_fg0    = "#bbc2cf"; # foreground  — text on every pill
        color_bg1    = "#21242b"; # near-black  — clock pill
        color_bg3    = "#3f444a"; # dark gray   — docker / conda pill
        color_blue   = "#2257a0"; # navy        — language pill
        color_aqua   = "#4db5bd"; # teal        — git pill
        color_green  = "#98be65"; # success prompt char
        color_orange = "#da8548"; # orange      — os / user pill
        color_purple = "#c678dd"; # vim-replace prompt char
        color_red    = "#ff6c6b"; # error prompt char
        color_yellow = "#ecbe7b"; # yellow      — directory pill
      };

      # ── OS ──────────────────────────────────────────────────────────────────
      os = {
        disabled = false;
        style    = "bg:color_orange fg:color_fg0";
        symbols  = {
          NixOS            = " ";
          Linux            = "󰌽 ";
          Macos            = "󰀵 ";
          Windows          = "󰍲 ";
          Ubuntu           = "󰕈 ";
          SUSE             = " ";
          Raspbian         = "󰐿 ";
          Mint             = "󰣭 ";
          Manjaro          = " ";
          Gentoo           = "󰣨 ";
          Fedora           = "󰣛 ";
          Alpine           = " ";
          Amazon           = " ";
          Android          = " ";
          AOSC             = " ";
          Arch             = "󰣇 ";
          Artix            = "󰣇 ";
          CentOS           = " ";
          Debian           = "󰣚 ";
          EndeavourOS      = " ";
          Pop              = " ";
          Redhat           = "󱄛 ";
          RedHatEnterprise = "󱄛 ";
        };
      };

      # ── Username ────────────────────────────────────────────────────────────
      username = {
        show_always = true;
        style_user  = "bg:color_orange fg:color_fg0";
        style_root  = "bg:color_orange fg:color_fg0";
        format      = "[ $user ]($style)";
      };

      # ── Directory ───────────────────────────────────────────────────────────
      directory = {
        style             = "fg:color_fg0 bg:color_yellow";
        format            = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions     = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music"     = "󰝚 ";
          "Pictures"  = " ";
          "Developer" = "󰲋 ";
          ".config"   = " ";
        };
      };

      # ── Git ─────────────────────────────────────────────────────────────────
      # The double-bracket pattern [[ inner ](style)]($style) ensures the
      # segment is hidden entirely when empty, while still letting the inner
      # content carry explicit fg + bg colours.
      git_branch = {
        symbol = "";
        style  = "bg:color_aqua";
        format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
      };

      git_status = {
        style  = "bg:color_aqua";
        format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
      };

      # ── Languages — all share the navy pill ─────────────────────────────────
      c = {
        symbol = " ";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      cpp = {
        symbol = " ";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      rust = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      golang = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      nodejs = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      bun = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      php = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      java = {
        symbol = " ";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      kotlin = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      haskell = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      python = {
        symbol = "";
        style  = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      # Bonus: Nix shell indicator — lights up inside nix develop / nix-shell
      nix_shell = {
        symbol      = " ";
        style       = "bg:color_blue";
        format      = "[[ $symbol$state ](fg:color_fg0 bg:color_blue)]($style)";
        impure_msg  = "impure";
        pure_msg    = "pure";
        unknown_msg = "?";
      };

      # ── Context (docker / conda) ────────────────────────────────────────────
      docker_context = {
        symbol = "";
        style  = "bg:color_bg3";
        format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
      };

      conda = {
        style  = "bg:color_bg3";
        format = "[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)";
      };

      # ── Clock ───────────────────────────────────────────────────────────────
      time = {
        disabled    = false;
        time_format = "%R";          # 24 h HH:MM
        style       = "bg:color_bg1";
        format      = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
      };

      # ── Line break (separates the pill row from the prompt character) ────────
      line_break.disabled = false;

      # ── Prompt character ────────────────────────────────────────────────────
      character = {
        disabled                  = false;
        success_symbol            = "[❯](bold fg:color_green)";
        error_symbol              = "[❯](bold fg:color_red)";
        vimcmd_symbol             = "[❮](bold fg:color_green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:color_purple)";
        vimcmd_replace_symbol     = "[❮](bold fg:color_purple)";
        vimcmd_visual_symbol      = "[❮](bold fg:color_yellow)";
      };
    };
  };
}

# starship-module.nix
# Starship prompt — Doom One Dark × Powerline
#
# Usage (home-manager):
#   imports = [ ./starship-module.nix ];
#
# Requires a Nerd Font (e.g. JetBrainsMono Nerd Font) in your terminal.
#
# Prompt layout:
#  [navy: os · user] ▶ [blue: dir] ▶ [purple: git] ▶ [teal: lang] ▶ [yellow: dur] ▶
#  ❯

{ lib, ... }:

let
  # ── Doom One Dark palette ──────────────────────────────────────────────────
  c = {
    bg     = "#282c34";
    fg     = "#bbc2cf";
    red    = "#ff6c6b";
    orange = "#da8548";
    yellow = "#ecbe7b";
    green  = "#98be65";
    teal   = "#4db5bd";
    blue   = "#51afef";
    navy   = "#2257a0";
    purple = "#c678dd";
    violet = "#a9a1e1";
    cyan   = "#46d9ff";
  };
in
{
  programs.starship = {
    enable = true;

    settings = {

      # ── Global ──────────────────────────────────────────────────────────────
      add_newline  = true;
      scan_timeout = 10;

      # Powerline format — each [](fg:PREV bg:NEXT) is the hard separator.
      format = lib.concatStrings [
        # ▌ navy pill: OS + username
        "[](fg:${c.navy})"
        "$os"
        "$username"
        # ▶ navy → blue
        "[](fg:${c.navy} bg:${c.blue})"
        # ▌ blue pill: directory
        "$directory"
        # ▶ blue → purple
        "[](fg:${c.blue} bg:${c.purple})"
        # ▌ purple pill: git
        "$git_branch"
        "$git_status"
        # ▶ purple → teal
        "[](fg:${c.purple} bg:${c.teal})"
        # ▌ teal pill: language versions + nix-shell
        "$nodejs"
        "$rust"
        "$python"
        "$golang"
        "$nix_shell"
        # ▶ teal → yellow
        "[](fg:${c.teal} bg:${c.yellow})"
        # ▌ yellow pill: command duration
        "$cmd_duration"
        # ▶ yellow → terminal
        "[](fg:${c.yellow})"
        # Second line: prompt character
        "\n$character"
      ];

      # ── OS ──────────────────────────────────────────────────────────────────
      os = {
        disabled = false;
        style    = "bg:${c.navy} fg:${c.fg}";
        symbols  = {
          NixOS   = " ";
          Linux   = " ";
          Macos   = " ";
          Windows = "󰍲 ";
          Ubuntu  = " ";
          Fedora  = " ";
          Arch    = " ";
          Debian  = " ";
          Pop     = " ";
        };
      };

      # ── Username ────────────────────────────────────────────────────────────
      username = {
        disabled    = false;
        show_always = true;
        style_user  = "bg:${c.navy} fg:${c.fg}";
        style_root  = "bg:${c.navy} fg:${c.red}";  # red tint for root
        format      = "[ $user ]($style)";
      };

      # ── Directory ───────────────────────────────────────────────────────────
      directory = {
        style             = "bg:${c.blue} fg:${c.bg}";
        format            = "[ $path ]($style)";
        truncation_length = 4;
        truncation_symbol = "…/";
        substitutions     = {
          "~"          = "~";
          "Documents"  = "󰈙 ";
          "Downloads"  = " ";
          "Music"      = " ";
          "Pictures"   = " ";
          "Projects"   = "󰲋 ";
          ".config"    = " ";
        };
      };

      # ── Git branch ──────────────────────────────────────────────────────────
      git_branch = {
        symbol = " ";
        style  = "bg:${c.purple} fg:${c.bg}";
        format = "[ $symbol$branch ]($style)";
      };

      # ── Git status ──────────────────────────────────────────────────────────
      git_status = {
        style      = "bg:${c.purple} fg:${c.bg}";
        format     = "([$all_status$ahead_behind ]($style))";
        conflicted = "⚡";
        ahead      = "⇡\${count}";
        behind     = "⇣\${count}";
        diverged   = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";       # clean — show nothing
        untracked  = "?";
        stashed    = "󰏗";
        modified   = "!";
        staged     = "+";
        renamed    = "»";
        deleted    = "✘";
      };

      # ── Node.js ─────────────────────────────────────────────────────────────
      nodejs = {
        symbol = " ";
        style  = "bg:${c.teal} fg:${c.bg}";
        format = "[ $symbol$version ]($style)";
      };

      # ── Rust ────────────────────────────────────────────────────────────────
      rust = {
        symbol = " ";
        style  = "bg:${c.teal} fg:${c.bg}";
        format = "[ $symbol$version ]($style)";
      };

      # ── Python ──────────────────────────────────────────────────────────────
      python = {
        symbol = " ";
        style  = "bg:${c.teal} fg:${c.bg}";
        format = "[ $symbol$version ]($style)";
      };

      # ── Go ──────────────────────────────────────────────────────────────────
      golang = {
        symbol = " ";
        style  = "bg:${c.teal} fg:${c.bg}";
        format = "[ $symbol$version ]($style)";
      };

      # ── Nix shell ───────────────────────────────────────────────────────────
      nix_shell = {
        symbol      = " ";
        style       = "bg:${c.teal} fg:${c.bg}";
        format      = "[ $symbol$state ]($style)";
        impure_msg  = "impure";
        pure_msg    = "pure";
        unknown_msg = "?";
      };

      # ── Command duration ────────────────────────────────────────────────────
      cmd_duration = {
        min_time          = 500;    # only show if command took ≥ 500 ms
        show_milliseconds = false;
        style             = "bg:${c.yellow} fg:${c.bg}";
        format            = "[ ⏱ $duration ]($style)";
      };

      # ── Prompt character ────────────────────────────────────────────────────
      character = {
        success_symbol = "[❯](bold ${c.green})";
        error_symbol   = "[❯](bold ${c.red})";
        vimcmd_symbol  = "[❮](bold ${c.blue})";
      };
    };
  };
}

# starship-module.nix
# Add to your flake's modules list like iriunwebcam-module.nix.
# Requires a Nerd Font in your terminal (e.g. JetBrainsMono Nerd Font).
#
# If you use home-manager, move the programs.starship block into your
# home-manager config verbatim — the settings attr set is identical.

{ lib, ... }:

{
  programs.starship = {
    enable = true;
    settings = {

      format = lib.concatStrings [
        "[](fg:violet)"
        "$os"
        "$username"
        "[](fg:violet bg:blue)"
        "$directory"
        "[](fg:blue bg:cyan)"
        "$git_branch"
        "$git_status"
        "[](fg:cyan bg:green)"
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
        "[](fg:green bg:bg2)"
        "$docker_context"
        "$conda"
        "[](fg:bg2 bg:bg1)"
        "$time"
        "[ ](fg:bg1)"
        "$line_break"
        "$character"
      ];

      palette = "doom_one";

      palettes.doom_one = {
        fg    = "#bbc2cf";
        bg1   = "#2c323c";   # darkest segment (time)
        bg2   = "#3e4451";   # mid-dark segment (docker/conda)
        red     = "#ff6c6b";
        orange  = "#da8548";
        yellow  = "#ecbe7b";
        green   = "#98be65";
        cyan    = "#46d9ff";
        blue    = "#51afef";
        violet  = "#c678dd";
        magenta = "#a9a1e1";
      };

      # ── Segments ────────────────────────────────────────────────────────

      os = {
        disabled = false;
        style = "bg:violet fg:fg";
      };

      os.symbols = {
        NixOS      = "󱄅";
        Linux      = "󰌽";
        Arch       = "󰣇";
        Debian     = "󰣚";
        Ubuntu     = "󰕈";
        Fedora     = "󰣛";
        Macos      = "󰀵";
        Windows    = "󰍲";
        Manjaro    = "";
        EndeavourOS = "";
      };

      username = {
        show_always  = true;
        style_user   = "bg:violet fg:fg";
        style_root   = "bg:red fg:fg";
        format       = "[ $user ]($style)";
      };

      directory = {
        style              = "bg:blue fg:fg";
        format             = "[ $path ]($style)";
        truncation_length  = 3;
        truncation_symbol  = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music"     = "󰝚 ";
          "Pictures"  = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style  = "bg:cyan";
        format = "[[ $symbol $branch ](fg:fg bg:cyan)]($style)";
      };

      git_status = {
        style  = "bg:cyan";
        format = "[[($all_status$ahead_behind )](fg:fg bg:cyan)]($style)";
      };

      # Language segments — all on green bg
      nodejs  = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      bun     = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      rust    = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      golang  = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      python  = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      c       = { symbol = " "; style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      cpp     = { symbol = " "; style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      java    = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      kotlin  = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      haskell = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };
      php     = { symbol = "";  style = "bg:green"; format = "[[ $symbol( $version) ](fg:fg bg:green)]($style)"; };

      docker_context = {
        symbol = "";
        style  = "bg:bg2";
        format = "[[ $symbol( $context) ](fg:cyan bg:bg2)]($style)";
      };

      conda = {
        style  = "bg:bg2";
        format = "[[ $symbol( $environment) ](fg:cyan bg:bg2)]($style)";
      };

      time = {
        disabled    = false;
        time_format = "%R";
        style       = "bg:bg1";
        format      = "[[  $time ](fg:fg bg:bg1)]($style)";
      };

      line_break.disabled = false;

      character = {
        disabled               = false;
        success_symbol         = "[❯](bold fg:green)";
        error_symbol           = "[❯](bold fg:red)";
        vimcmd_symbol          = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:violet)";
        vimcmd_replace_symbol  = "[❮](bold fg:violet)";
        vimcmd_visual_symbol   = "[❮](bold fg:yellow)";
      };

    };
  };
}

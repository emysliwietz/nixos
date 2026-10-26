{ config, lib, pkgs, ... }:

let
  # mpv's stock OSC, patched to show thumbfast previews while hovering the
  # seekbar. Built from mpv's own source so it tracks the mpv version; if the
  # patch stops applying after an update, the rebuild fails loudly.
  osc-thumbfast = pkgs.mpvScripts.buildLua {
    pname = "osc-thumbfast";
    inherit (pkgs.mpv-unwrapped) version src;
    patches = [ ./mpv/osc-thumbfast.patch ];
    scriptPath = "player/lua/osc.lua";
    # replaces the built-in OSC
    passthru.extraWrapperArgs = [ "--add-flags" "--osc=no" ];
  };

  mpv = pkgs.mpv.override {
    scripts = with pkgs.mpvScripts; [
      osc-thumbfast
      thumbfast
      mpris
      sponsorblock-minimal
    ];
  };
in
{
  home-manager.users.user = {
    home.packages = [
      (pkgs.writeShellScriptBin "mpv" ''
        exec nvidia-offload ${mpv}/bin/mpv "$@"
      '')

      (pkgs.writeShellScriptBin "mpv-cpu" ''
        exec ${mpv}/bin/mpv "$@"
      '')
    ];

    # thumbnails for yt-dlp streams too, not just local files
    xdg.configFile."mpv/script-opts/thumbfast.conf".text = ''
      network=yes
    '';
  };
}

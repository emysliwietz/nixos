{ config, pkgs, lib, ... }:

let
  moduleDir = ./hyprland;

  # Deploy only whitelisted scripts from a directory
  deployWhitelistedScripts = srcDir: destPrefix: names:
    lib.foldl' (acc: name: acc // {
      "hypr/${destPrefix}/${name}" = {
        source = srcDir + "/${name}";
        executable = true;
      };
    }) {} names;

  # Deploy all regular files from a directory (for animation presets)
  deployFiles = srcDir: destPrefix:
    let
      entries = builtins.readDir srcDir;
      files = lib.filterAttrs (_: v: v == "regular") entries;
    in lib.mapAttrs' (name: _: {
      name = "hypr/${destPrefix}/${name}";
      value = { source = srcDir + "/${name}"; };
    }) files;

  # Whitelisted scripts — only these get deployed.
  # Removed: LockScreen.sh (inlined), KillActiveProcess.sh (inlined),
  #   Polkit.sh (direct store path), Polkit-NixOS.sh, SwitchKeyboardLayout.sh,
  #   KooLsDotsUpdate.sh, Distro_update.sh, PortalHyprland.sh (all NixOS-irrelevant)
  coreScripts = [
    "Volume.sh"
    "Brightness.sh"
    "BrightnessKbd.sh"
    "MediaCtrl.sh"
    "ScreenShot.sh"
    "Sounds.sh"           # no-op (exits immediately) but referenced by Volume/ScreenShot
    "Refresh.sh"
    "RefreshNoWaybar.sh"
    "GameMode.sh"
    "WallustSwww.sh"
    "Wlogout.sh"
    "ClipManager.sh"
    "ChangeBlur.sh"
    "ChangeLayout.sh"
    "TouchPad.sh"
    "AirplaneMode.sh"
    "Animations.sh"
    "WaybarStyles.sh"
    "WaybarLayout.sh"
    "WaybarScripts.sh"
    "WaybarCava.sh"
    "RofiThemeSelector.sh"
    "RofiThemeSelector-modified.sh"
    "RofiEmoji.sh"        # large (embedded emoji database)
    "KeyBinds.sh"
    "KeyHints.sh"
    "Kool_Quick_Settings.sh"
    "DarkLight.sh"
    "Hypridle.sh"
    "Kitty_themes.sh"
    "MonitorProfiles.sh"
    "RofiSearch.sh"
    "UptimeNixOS.sh"      # referenced by hyprlock
  ];

  # Removed: ZshChangeTheme.sh (exits on NixOS), WallpaperAutoChange.sh (unused),
  #   RainbowBorders.bak.sh (backup file)
  userScripts = [
    "WallpaperSelect.sh"
    "WallpaperRandom.sh"
    "WallpaperEffects.sh"
    "RofiBeats.sh"
    "RofiCalc.sh"
    "Weather.sh"
  ];

in {

  # ── System packages (only what's NOT already in other modules) ─────
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprlock
    hypridle
    hyprcursor

    # Bar, notifications, widgets
    waybar
    swaynotificationcenter
    ags

    # Launcher & power menu
    rofi
    wlogout

    # Wallpaper & color generation
    swww
    wallust

    # Screenshots (flameshot in its own module)
    grim
    slurp
    swappy

    # Clipboard history
    cliphist

    # Tray applets
    networkmanagerapplet
    blueman

    # Audio & brightness
    pavucontrol
    pamixer
    playerctl
    brightnessctl

    # Theming
    kdePackages.breeze
    nwg-look
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # Polkit agent (KDE, matches existing Plasma6 session)
    kdePackages.polkit-kde-agent-1

    # Night light
    wlsunset

    # OSD popups (volume, brightness, caps lock — like KDE)
    swayosd

    # Auto-mount drives
    udiskie

    # Tools used by scripts
    jq
    socat
    yad
    kdePackages.ark
  ];


  fonts.packages = with pkgs; [
    victor-mono
    jetbrains-mono
  ];

  # ── Home-manager ───────────────────────────────────────────────────
  home-manager.users.user = { pkgs, lib, ... }: {

    # ────────────────────────────────────────────────────────────────
    # Hyprland compositor — all config via settings attrset
    # ────────────────────────────────────────────────────────────────
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true; # handles dbus env export automatically

      plugins = [
        pkgs.hyprlandPlugins.hyprexpo    # workspace grid overview (Super+`)
        pkgs.hyprlandPlugins.hyprtrails  # cursor trail effect
        pkgs.hyprlandPlugins.hyprwinwrap # use any app as wallpaper
        pkgs.hyprlandPlugins.hyprfocus   # flash animation on focus change
        pkgs.hyprlandPlugins.hyprspace   # macOS Mission Control overview
      ];
      # To add liquid-glass plugin, add its flake input and append:
      # ++ [ hyprglass.packages.${pkgs.stdenv.hostPlatform.system}.default ]

      settings = {

        # ── Variables ────────────────────────────────────────────
        "$mainMod" = "SUPER";
        "$scriptsDir" = "$HOME/.config/hypr/scripts";
        "$UserScripts" = "$HOME/.config/hypr/UserScripts";
        "$term" = "kitty";
        "$files" = "thunar";
        "$wallDIR" = "$HOME/Pictures/wallpapers";
        "$edit" = "\${EDITOR:-emacsclient}";
        "$Search_Engine" = "https://duckduckgo.com/?q={}";

        # Default wallust colors (overridden at runtime via source below)
        "$background" = "rgb(151517)";
        "$foreground" = "rgb(F3F4F5)";
        "$color0" = "rgb(3C3C3E)";
        "$color1" = "rgb(0E1016)";
        "$color2" = "rgb(101218)";
        "$color3" = "rgb(383731)";
        "$color4" = "rgb(383831)";
        "$color5" = "rgb(706958)";
        "$color6" = "rgb(A5A7AA)";
        "$color7" = "rgb(E5E7E8)";
        "$color8" = "rgb(A0A1A2)";
        "$color9" = "rgb(12151E)";
        "$color10" = "rgb(161820)";
        "$color11" = "rgb(4B4A41)";
        "$color12" = "rgb(4B4A41)";
        "$color13" = "rgb(958C76)";
        "$color14" = "rgb(DCDFE2)";
        "$color15" = "rgb(E5E7E8)";

        # Runtime source — wallust colors (created by wallust at runtime)
        source = [
          "$HOME/.config/hypr/wallust/wallust-hyprland.conf"
        ];

        # ── Monitors ────────────────────────────────────────────
        # kanshi (below) handles multi-monitor profiles automatically.
        # This wildcard fallback handles any unrecognized output.
        monitor = ", preferred, auto, 1";

        # ── Workspace → monitor assignments ─────────────────────
        workspace = [
          "1, monitor:eDP-1, default:true"
          "2, monitor:eDP-1"
          "3, monitor:eDP-1"
          "4, monitor:eDP-1"
          "5, monitor:eDP-1"
          "6, monitor:HDMI-A-2, default:true"
          "7, monitor:HDMI-A-2"
          "8, monitor:HDMI-A-2"
          "9, monitor:DP-3, default:true"
          "10, monitor:DP-3"
        ];

        # ── Environment ──────────────────────────────────────────
        env = [
          "GDK_BACKEND,wayland,x11,*"
          "QT_QPA_PLATFORM,wayland;xcb"
          "CLUTTER_BACKEND,wayland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "HYPRCURSOR_THEME,breeze_cursors"
          "HYPRCURSOR_SIZE,24"
          "MOZ_ENABLE_WAYLAND,1"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "LIBVA_DRIVER_NAME,iHD"
          "WLR_RENDERER_ALLOW_SOFTWARE,1"
          "EDITOR,vim"
        ];

        # ── Startup ──────────────────────────────────────────────
        # hypridle + wlsunset are started via systemd services (see below).
        # dbus env export is handled by systemd.enable = true.
        # Polkit uses direct Nix store path — no script needed.
        exec-once = [
          "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
          "swayosd-server"
          "swww-daemon --format xrgb"
          ''bash -c 'sleep 2; while true; do swww img "$(find /home/user/dox/wallpapers -type f | shuf -n1)" --transition-type grow --transition-duration 1.5 --transition-fps 60; sleep 900; done' ''
          "nm-applet --indicator"
          "swaync"
          "ags"
          "blueman-applet"
          "waybar"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "/home/user/.scripts/keepassunlock"
          "signal-desktop --start-in-tray --no-sandbox --password-store=gnome-libsecret"
          "emacs --bg-daemon"
        ];

        # ── Input ────────────────────────────────────────────────
        # kb_options left empty — keyd already remaps capslock→ctrl/esc
        # system-wide (services.keyd in configuration.nix).
        input = {
          kb_layout = "de";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          repeat_rate = 50;
          repeat_delay = 300;
          sensitivity = 0;
          numlock_by_default = true;
          left_handed = false;
          follow_mouse = true;
          float_switch_override_focus = false;
          natural_scroll = true;

          touchpad = {
            disable_while_typing = true;
            natural_scroll = true;
            clickfinger_behavior = false;
            middle_button_emulation = true;
            "tap-to-click" = true;
            drag_lock = false;
          };

          touchdevice.enabled = true;
          tablet = { transform = 0; left_handed = 0; };
        };

        # ── General ──────────────────────────────────────────────
        general = {
          border_size = 1;
          gaps_in = 3;
          gaps_out = 5;
          resize_on_border = true;
          layout = "dwindle";
          # Teal-to-indigo gradient (teal from your KDE accent #00D3B8)
          # Combined with borderangle animation below, this rotates!
          "col.active_border" = "rgb(00D3B8) rgb(6C5CE7) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          allow_tearing = false;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          special_scale_factor = 0.8;
        };

        master = {
          new_status = "master";
          new_on_top = 1;
          mfact = 0.5;
        };

        # ── Decoration ───────────────────────────────────────────
        decoration = {
          rounding = 12;
          active_opacity = 1.0;
          inactive_opacity = 0.92;
          fullscreen_opacity = 1.0;
          dim_inactive = false;
          dim_strength = 0;
          dim_special = 0.8;

          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
            color = "rgba(00000055)";
          };

          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            ignore_opacity = true;
            new_optimizations = true;
            special = true;
            popups = true;
          };
        };

        # ── Animations ───────────────────────────────────────────
        animations = {
          enabled = true;
          bezier = [
            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.5, 0, 0.99, 0.99"
            "smoothIn, 0.5, -0.5, 0.68, 1.5"
            "snappy, 0.2, 1.0, 0.3, 1.0"
            "bounce, 0.68, -0.6, 0.32, 1.6"
          ];
          animation = [
            "windows, 1, 5, snappy, popin 80%"         # pop in from 80%
            "windowsIn, 1, 4, bounce, popin 60%"        # bouncy pop-in
            "windowsOut, 1, 3, smoothOut, popin 80%"    # pop out
            "windowsMove, 1, 4, snappy, slide"
            "border, 1, 1, liner"                       # instant border flash on focus
            "borderangle, 1, 50, liner, loop"           # rotating gradient border!
            "fade, 1, 3, smoothOut"
            "fadeDim, 1, 4, smoothIn"                   # smooth dim transition
            "workspaces, 1, 4, overshot, slidefade 30%" # slide + fade
            "specialWorkspace, 1, 4, bounce, slidefadevert -30%"
          ];
        };

        group = {
          "col.border_active" = "$color15";
          groupbar."col.active" = "$color0";
        };

        # ── Gestures ─────────────────────────────────────────────
        # workspace_swipe* removed in Hyprland 0.52 (always enabled now)
        gestures = {};

        # ── Misc ─────────────────────────────────────────────────
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vfr = true;
          mouse_move_enables_dpms = true;
          # Window swallowing: opening an app from kitty replaces kitty's
          # window; closing the app brings kitty back. Feels very snappy.
          enable_swallow = true;
          swallow_regex = "^(kitty)$";
          focus_on_activate = false;
          initial_workspace_tracking = 0;
          middle_click_paste = false;
        };

        binds = {
          workspace_back_and_forth = true;
          allow_workspace_cycles = true;
          pass_mouse_when_bound = false;
        };

        xwayland.force_zero_scaling = true;

        # explicit_sync removed in Hyprland 0.52 (always on now)
        render = {
          direct_scanout = 0;
        };

        cursor = {
          no_hardware_cursors = 2;
          enable_hyprcursor = true;
          warp_on_change_workspace = true;
          no_warps = true;
          inactive_timeout = 3;
        };

        # ── Hyprexpo — workspace grid overview (like KDE Desktop Grid)
        plugin.hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current";
          enable_gesture = true;
          gesture_distance = 300;
          gesture_positive = true;
        };

        # ── Hyprtrails — cursor trail effect
        plugin.hyprtrails = {
          color = "rgba(00D3B8aa)"; # teal trail matching border gradient
        };

        # ── Hyprfocus — disabled (user prefers border-only focus indicator)
        plugin.hyprfocus = {
          enabled = false;
        };

        # ── Hyprspace — macOS Mission Control-like overview
        plugin.overview = {
          panelHeight = 150;
          panelBorderWidth = 2;
          workspaceActiveBorder = "rgb(00D3B8)"; # teal accent
          workspaceInactiveBorder = "rgba(595959aa)";
          dragAlpha = 0.8;
          autoDrag = true;       # drag windows in overview
          autoScroll = true;     # scroll to switch workspaces
          exitOnClick = true;
          exitOnSwitch = true;
          showNewWorkspace = true;
          showEmptyWorkspace = true;
        };

        # ── Hyprwinwrap — use a program as wallpaper
        # Start your wallpaper app with the class "hyprwinwrap", e.g.:
        #   kitty --class hyprwinwrap -e cava
        #   kitty --class hyprwinwrap -e cmatrix
        #   mpv --wid=0 --loop video.mp4  (use windowrule instead)
        plugin.hyprwinwrap = {
          class = "hyprwinwrap";
        };

        # ── Touchpad device ──────────────────────────────────────
        device = {
          name = "asue1209:00-04f3:319f-touchpad";
          enabled = true;
        };

        # ── Window rules ─────────────────────────────────────────
        windowrule = [
          # Tags: browsers
          "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$"
          "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
          "tag +browser, class:^(chrome-.+-Default)$"
          "tag +browser, class:^([Cc]hromium)$"
          "tag +browser, class:^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$"
          "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
          "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
          "tag +browser, class:^(zen-alpha|zen)$"

          # Tags: notifications
          "tag +notif, class:^(swaync-control-center|swaync-notification-window|swaync-client|class)$"

          # Tags: terminals
          "tag +terminal, class:^(Alacritty|kitty|kitty-dropterm)$"

          # Tags: email
          "tag +email, class:^([Tt]hunderbird|org.gnome.Evolution)$"
          "tag +email, class:^(eu.betterbird.Betterbird)$"

          # Tags: IDEs
          "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
          "tag +projects, class:^(VSCode|code-url-handler)$"
          "tag +projects, class:^(jetbrains-.+)$"

          # Tags: screen share
          "tag +screenshare, class:^(com.obsproject.Studio)$"

          # Tags: IM
          "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
          "tag +im, class:^([Ff]erdium)$"
          "tag +im, class:^([Ww]hatsapp-for-linux)$"
          "tag +im, class:^(ZapZap|com.rtosta.zapzap)$"
          "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
          "tag +im, class:^(teams-for-linux)$"

          # Tags: games
          "tag +games, class:^(gamescope)$"
          "tag +games, class:^(steam_app_\\d+)$"
          "tag +gamestore, class:^([Ss]team)$"
          "tag +gamestore, title:^([Ll]utris)$"
          "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"

          # Tags: file managers
          "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
          "tag +file-manager, class:^(app.drey.Warp)$"

          # Tags: multimedia
          "tag +wallpaper, class:^([Ww]aytrogen)$"
          "tag +multimedia, class:^([Aa]udacious)$"
          "tag +multimedia_video, class:^([Mm]pv|vlc)$"

          # Tags: settings & viewers
          "tag +settings, title:^(ROG Control)$"
          "tag +settings, class:^(wihotspot(-gui)?)$"
          "tag +settings, class:^([Bb]aobab|org.gnome.[Bb]aobab)$"
          "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
          "tag +settings, title:(Kvantum Manager)"
          "tag +settings, class:^(file-roller|org.gnome.FileRoller|org.kde.ark)$"
          "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
          "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
          "tag +settings, class:^(qt5ct|qt6ct|[Yy]ad)$"
          "tag +settings, class:(xdg-desktop-portal-gtk)"
          "tag +settings, class:^(org.kde.polkit-kde-authentication-agent-1)$"
          "tag +settings, class:^([Rr]ofi)$"
          "tag +viewer, class:^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$"
          "tag +viewer, class:^(evince)$"
          "tag +viewer, class:^(eog|org.gnome.Loupe)$"
          "tag +KooL_Cheat, title:^(KooL Quick Cheat Sheet)$"
          "tag +KooL_Settings, title:^(KooL Hyprland Settings)$"
          "tag +KooL-Settings, class:^(nwg-displays|nwg-look)$"

          # Overrides
          "noblur, tag:multimedia_video*"
          "opacity 1.0, tag:multimedia_video*"

          # Positions
          "center, tag:KooL_Cheat*"
          "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
          "center, title:^(ROG Control)$"
          "center, tag:KooL-Settings*"
          "center, title:^(Keybindings)$"
          "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
          "center, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$"
          "center, class:^([Ff]erdium)$"
          "move 72% 7%,title:^(Picture-in-Picture)$"

          # Idle inhibit
          "idleinhibit fullscreen, fullscreen:1"

          # Float
          "float, tag:KooL_Cheat*"
          "float, tag:wallpaper*"
          "float, tag:settings*"
          "float, tag:viewer*"
          "float, tag:KooL-Settings*"
          "float, class:([Zz]oom|onedriver|onedriver-launcher)$"
          "float, class:(org.gnome.Calculator), title:(Calculator)"
          "float, class:^(com.github.rafostar.Clapper)$"
          "float, class:^([Qq]alculate-gtk)$"
          "float, class:^([Ff]erdium)$"
          "float, title:^(Picture-in-Picture)$"
          "float, title:^(Authentication Required)$"
          "center, title:^(Authentication Required)$"
          "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
          "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
          "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
          "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
          "float, title:^(Add Folder to Workspace)$"
          "size 70% 60%, title:^(Add Folder to Workspace)$"
          "center, title:^(Add Folder to Workspace)$"
          "float, title:^(Save As)$"
          "size 70% 60%, title:^(Save As)$"
          "center, title:^(Save As)$"
          "float, initialTitle:(Open Files)"
          "size 70% 60%, initialTitle:(Open Files)"
          "float, title:^(SDDM Background)$"
          "center, title:^(SDDM Background)$"
          "size 16% 12%, title:^(SDDM Background)$"

          # Opacity
          "opacity 0.9 0.7, tag:browser*"
          "opacity 0.9 0.8, tag:projects*"
          "opacity 0.94 0.86, tag:im*"
          "opacity 0.94 0.86, tag:multimedia*"
          "opacity 0.9 0.8, tag:file-manager*"
          "opacity 0.97 0.95, tag:terminal*"
          "opacity 0.8 0.7, tag:settings*"
          "opacity 0.82 0.75, tag:viewer*"
          "opacity 0.9 0.7, tag:wallpaper*"
          "opacity 0.8 0.7, class:^(gedit|org.gnome.TextEditor|mousepad)$"
          "opacity 0.9 0.8, class:^(deluge)$"
          "opacity 0.9 0.8, class:^(im.riot.Riot)$"
          "opacity 0.9 0.8, class:^(seahorse)$"
          "opacity 0.95 0.75, title:^(Picture-in-Picture)$"

          # Size
          "size 65% 90%, tag:KooL_Cheat*"
          "size 70% 70%, tag:wallpaper*"
          "size 70% 70%, tag:settings*"
          "size 60% 70%, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$"
          "size 60% 70%, class:^([Ff]erdium)$"

          # Pin & aspect
          "pin, title:^(Picture-in-Picture)$"
          "keepaspectratio, title:^(Picture-in-Picture)$"

          # Games
          "noblur, tag:games*"
          "fullscreen, tag:games*"

          # Firefox: full opacity override
          "opacity 1.0 override 1.0 override, class:^(firefox)$"

          # swaync: borderless
          "noborder, class:^(swaync)$"
          "bordersize 0, class:^(swaync)$"

          # Zotero citation dialog
          "float, class:^(Zotero)$, title:^(Citation Dialog)$"
          "center, class:^(Zotero)$, title:^(Citation Dialog)$"

          # KDE Connect (presentation mode)
          "opacity 1, title:KDE Connect Daemon"
          "noblur, title:KDE Connect Daemon"
          "noborder, title:KDE Connect Daemon"
          "noshadow, title:KDE Connect Daemon"
          "noanim, title:KDE Connect Daemon"
          "nofocus, title:KDE Connect Daemon"
          "suppressevent fullscreen, title:KDE Connect Daemon"
          "float, title:KDE Connect Daemon"
          "pin, title:KDE Connect Daemon"
          "minsize 4000 1920, title:KDE Connect Daemon"
          "move 0 0, title:KDE Connect Daemon"
        ];

        layerrule = [
          "blur, rofi"
          "ignorezero, rofi"
          "blur, notifications"
          "ignorezero, notifications"
          "blur, waybar"
          "ignorezero, waybar"
          "blur, swaync-notification-window"
          "ignorezero, swaync-notification-window"
          "blur, swaync-control-center"
          "ignorezero, swaync-control-center"
          "blur, swayosd"
        ];

        # ── Keybinds ─────────────────────────────────────────────
        bind = [
          # Workspace overview grid (like KDE Desktop Grid)
          "$mainMod, grave, hyprexpo:expo, toggle"
          # Mission Control overview (like macOS — shows all windows)
          "$mainMod, o, overview:toggle,"

          # Session — LockScreen and KillActiveProcess inlined (no script)
          "CTRL ALT, Delete, exec, hyprctl dispatch exit 0"
          "$mainMod, Q, killactive,"
          ''$mainMod SHIFT, Q, exec, kill "$(hyprctl -j activewindow | jq '.pid')"''
          "$mainMod, X, exec, pidof hyprlock || hyprlock -q"
          "CTRL ALT, P, exec, $scriptsDir/Wlogout.sh"
          "$mainMod SHIFT, N, exec, swaync-client -t -sw"
          "$mainMod SHIFT, E, exec, $scriptsDir/Kool_Quick_Settings.sh"

          # Launchers
          ''$mainMod, D, exec, pkill rofi || true && PATH="$PATH:/home/user/.scripts/" rofi -show run -modi run,drun''
          "$mainMod, S, exec, pkill rofi || true && rofi -show window -modi window,filebrowser"
          "$mainMod, Return, exec, $term"
          "$mainMod, space, exec, $files"
          ''$mainMod, backspace, exec, emacsclient -a "" -c''
          "$mainMod, A, exec, pkill rofi || true && ags -t 'overview'"
          ''$mainMod shift, B, exec, xdg-open "https://"''
          "$mainMod, B, exec, bash /home/user/.scripts/browser 2>/tmp/hyprlandbrowser"

          # Layout control
          "$mainMod CTRL, D, layoutmsg, removemaster"
          "$mainMod, I, layoutmsg, addmaster"
          "$mainMod CTRL, Return, layoutmsg, swapwithmaster"
          "$mainMod, T, togglesplit"
          "$mainMod, P, pseudo,"
          "$mainMod, F, fullscreen"
          "$mainMod SHIFT, F, fullscreen, 1"
          "$mainMod, G, togglefloating,"
          "$mainMod ALT, SPACE, exec, hyprctl dispatch workspaceopt allfloat"
          "$mainMod SHIFT, Return, exec, [float; move 15% 5%; size 70% 60%] $term"

          # Focus (hjkl)
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Move windows
          "$mainMod CTRL, h, movewindow, l"
          "$mainMod CTRL, l, movewindow, r"
          "$mainMod CTRL, k, movewindow, u"
          "$mainMod CTRL, j, movewindow, d"

          # Swap windows
          "$mainMod ALT, h, swapwindow, l"
          "$mainMod ALT, l, swapwindow, r"
          "$mainMod ALT, k, swapwindow, u"
          "$mainMod ALT, j, swapwindow, d"

          # Groups / alt-tab
          "$mainMod CTRL, tab, changegroupactive"
          "ALT, tab, cyclenext"
          "ALT, tab, bringactivetotop"

          # Workspaces (code:NN = layout-independent for DE keyboard)
          "$mainMod, code:10, workspace, 1"
          "$mainMod, code:11, workspace, 2"
          "$mainMod, code:12, workspace, 3"
          "$mainMod, code:13, workspace, 4"
          "$mainMod, code:14, workspace, 5"
          "$mainMod, code:15, workspace, 6"
          "$mainMod, code:16, workspace, 7"
          "$mainMod, code:17, workspace, 8"
          "$mainMod, code:18, workspace, 9"
          "$mainMod, code:19, workspace, 10"

          "$mainMod SHIFT, code:10, movetoworkspace, 1"
          "$mainMod SHIFT, code:11, movetoworkspace, 2"
          "$mainMod SHIFT, code:12, movetoworkspace, 3"
          "$mainMod SHIFT, code:13, movetoworkspace, 4"
          "$mainMod SHIFT, code:14, movetoworkspace, 5"
          "$mainMod SHIFT, code:15, movetoworkspace, 6"
          "$mainMod SHIFT, code:16, movetoworkspace, 7"
          "$mainMod SHIFT, code:17, movetoworkspace, 8"
          "$mainMod SHIFT, code:18, movetoworkspace, 9"
          "$mainMod SHIFT, code:19, movetoworkspace, 10"
          "$mainMod SHIFT, bracketleft, movetoworkspace, -1"
          "$mainMod SHIFT, bracketright, movetoworkspace, +1"

          "$mainMod CTRL, code:10, movetoworkspacesilent, 1"
          "$mainMod CTRL, code:11, movetoworkspacesilent, 2"
          "$mainMod CTRL, code:12, movetoworkspacesilent, 3"
          "$mainMod CTRL, code:13, movetoworkspacesilent, 4"
          "$mainMod CTRL, code:14, movetoworkspacesilent, 5"
          "$mainMod CTRL, code:15, movetoworkspacesilent, 6"
          "$mainMod CTRL, code:16, movetoworkspacesilent, 7"
          "$mainMod CTRL, code:17, movetoworkspacesilent, 8"
          "$mainMod CTRL, code:18, movetoworkspacesilent, 9"
          "$mainMod CTRL, code:19, movetoworkspacesilent, 10"
          "$mainMod CTRL, bracketleft, movetoworkspacesilent, -1"
          "$mainMod CTRL, bracketright, movetoworkspacesilent, +1"

          "$mainMod, tab, workspace, m+1"
          "$mainMod SHIFT, tab, workspace, m-1"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "$mainMod, period, workspace, e+1"
          "$mainMod, comma, workspace, e-1"

          # Special workspace
          "$mainMod SHIFT, U, movetoworkspace, special"
          "$mainMod, U, togglespecialworkspace,"

          # Scripts & features
          "$mainMod, Z, exec, $HOME/.scripts/dictionary.sh 2>/tmp/test"
          "$mainMod ALT, R, exec, $scriptsDir/Refresh.sh"
          "$mainMod ALT, E, exec, $scriptsDir/RofiEmoji.sh"
          "$mainMod ALT, O, exec, $scriptsDir/ChangeBlur.sh"
          "$mainMod SHIFT, G, exec, $scriptsDir/GameMode.sh"
          "$mainMod ALT, L, exec, $scriptsDir/ChangeLayout.sh"
          "$mainMod ALT, V, exec, $scriptsDir/ClipManager.sh"
          "$mainMod CTRL, R, exec, $scriptsDir/RofiThemeSelector.sh"
          "$mainMod CTRL SHIFT, R, exec, pkill rofi || true && $scriptsDir/RofiThemeSelector-modified.sh"
          "$mainMod CTRL, O, exec, hyprctl setprop active opaque toggle"
          "$mainMod SHIFT ALT, K, exec, $scriptsDir/KeyBinds.sh"
          "$mainMod SHIFT, A, exec, $scriptsDir/Animations.sh"
          "$mainMod ALT, C, exec, $UserScripts/RofiCalc.sh"
          "$mainMod SHIFT, M, exec, $UserScripts/RofiBeats.sh"
          "$mainMod, W, exec, $UserScripts/WallpaperSelect.sh"
          "$mainMod SHIFT, W, exec, $UserScripts/WallpaperEffects.sh"
          "CTRL ALT, W, exec, $UserScripts/WallpaperRandom.sh"
          "$mainMod SHIFT, T, exec, python3 /home/user/.scripts/dictionary/dictionary.py"
          "$mainMod SHIFT, K, exec, SDL_VIDEODRIVER=x11 DISPLAY=:1 /home/user/.nix-profile/bin/koreader"

          # Audio profile toggle
          ''$mainMod, F12, exec, c=$(pactl list cards short | awk '$2~/^alsa_card/ && $2!~/usb|bluetooth|hdmi/{print $2;exit}'); p=$(pactl list cards | awk -v c="$c" '/Name: /&&$2==c{f=1} f&&/Active Profile:/{print $3;exit}'); pactl set-card-profile "$c" "$([ "$p" = output:analog-stereo ] && echo output:analog-stereo+input:analog-stereo || echo output:analog-stereo)"''

          # Waybar
          "$mainMod CTRL ALT, B, exec, pkill -SIGUSR1 waybar"
          "$mainMod CTRL, B, exec, $scriptsDir/WaybarStyles.sh"
          "$mainMod ALT, B, exec, $scriptsDir/WaybarLayout.sh"

          # Screenshots
          ''$mainMod, Print, exec, grim -g "$(slurp)" - | swappy -f -''
          "$mainMod SHIFT, S, exec, $scriptsDir/ScreenShot.sh --swappy"
          "$mainMod, F6, exec, $scriptsDir/ScreenShot.sh --now"
          "$mainMod SHIFT, F6, exec, $scriptsDir/ScreenShot.sh --area"
          "$mainMod CTRL, F6, exec, $scriptsDir/ScreenShot.sh --in5"
          "$mainMod ALT, F6, exec, $scriptsDir/ScreenShot.sh --in10"
          "ALT, F6, exec, $scriptsDir/ScreenShot.sh --active"

          # Zoom
          ''$mainMod ALT, mouse_down, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')"''
          ''$mainMod ALT, mouse_up, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')"''

          # Laptop: ASUS keys
          ", xf86Launch1, exec, rog-control-center"
          ", xf86Launch3, exec, asusctl led-mode -n"
          ", xf86Launch4, exec, asusctl profile -n"
          ", xf86TouchpadToggle, exec, $scriptsDir/TouchPad.sh"
        ];

        binde = [
          "$mainMod SHIFT, h, resizeactive,-50 0"
          "$mainMod SHIFT, l, resizeactive,50 0"
          "$mainMod SHIFT, k, resizeactive,0 -50"
          "$mainMod SHIFT, j, resizeactive,0 50"
          # Brightness — SwayOSD shows a nice popup arc
          ", xf86MonBrightnessDown, exec, swayosd-client --brightness lower"
          ", xf86MonBrightnessUp, exec, swayosd-client --brightness raise"
          ", xf86KbdBrightnessDown, exec, $scriptsDir/BrightnessKbd.sh --dec"
          ", xf86KbdBrightnessUp, exec, $scriptsDir/BrightnessKbd.sh --inc"
        ];

        # Volume — SwayOSD shows a nice popup arc (like KDE)
        bindel = [
          ", xf86audioraisevolume, exec, swayosd-client --output-volume raise"
          ", xf86audiolowervolume, exec, swayosd-client --output-volume lower"
        ];

        bindl = [
          ", xf86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
          ", xf86audiomute, exec, swayosd-client --output-volume mute-toggle"
          ", xf86Sleep, exec, systemctl suspend"
          ", xf86Rfkill, exec, $scriptsDir/AirplaneMode.sh"
          ", xf86AudioPlayPause, exec, $scriptsDir/MediaCtrl.sh --pause"
          ", xf86AudioPause, exec, $scriptsDir/MediaCtrl.sh --pause"
          ", xf86AudioPlay, exec, $scriptsDir/MediaCtrl.sh --pause"
          ", xf86AudioNext, exec, $scriptsDir/MediaCtrl.sh --nxt"
          ", xf86AudioPrev, exec, $scriptsDir/MediaCtrl.sh --prv"
          ", xf86audiostop, exec, $scriptsDir/MediaCtrl.sh --stop"
        ];

        # Caps lock indicator popup
        bindr = [
          ", Caps_Lock, exec, swayosd-client --caps-lock"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      }; # end settings
    }; # end wayland.windowManager.hyprland

    # ────────────────────────────────────────────────────────────────
    # Hypridle (systemd service, NOT exec-once)
    # ────────────────────────────────────────────────────────────────
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };
        listener = [
          {
            timeout = 540;
            on-timeout = "notify-send 'Idle' 'You are idle!'";
            on-resume = "notify-send 'Welcome back!' 'Session resumed'";
          }
          {
            timeout = 600;
            on-timeout = "loginctl lock-session";
          }
        ];
      };
    };

    # ────────────────────────────────────────────────────────────────
    # Hyprlock — uses extraConfig for wallust source ordering
    # ────────────────────────────────────────────────────────────────
    programs.hyprlock = {
      enable = true;
      extraConfig = ''
        source = $HOME/.config/hypr/wallust/wallust-hyprland.conf
        $Scripts = $HOME/.config/hypr/scripts

        general {
            grace = 1
            fractional_scaling = 1
            immediate_render = true
        }

        background {
            monitor =
            path = $HOME/.config/hypr/wallpaper_effects/.wallpaper_current
            color = rgb(0,0,0)
            blur_size = 3
            blur_passes = 2
            noise = 0.0117
            contrast = 1.3000
            brightness = 0.8000
            vibrancy = 0.2100
            vibrancy_darkness = 0.0
        }

        label {
            monitor =
            text = cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B')" </b>"
            color = $color13
            font_size = 16
            font_family = Victor Mono Bold Italic
            position = 0, -120
            halign = center
            valign = center
        }

        label {
            monitor =
            text = cmd[update:1000] echo "$(date +"%H")"
            color = $color13
            font_size = 100
            font_family = JetBrainsMono Nerd Font ExtraBold
            position = 0, -100
            halign = center
            valign = top
        }

        label {
            monitor =
            text = cmd[update:1000] echo "$(date +"%M")"
            color = $color12
            font_size = 100
            font_family = JetBrainsMono Nerd Font ExtraBold
            position = 0, -250
            halign = center
            valign = top
        }

        label {
            monitor =
            text = cmd[update:1000] echo "$(date +"%S")"
            color = $color11
            font_size = 17
            font_family = JetBrainsMono Nerd Font ExtraBold
            position = 0, -410
            halign = center
            valign = top
        }

        label {
            monitor =
            text =   $USER
            color = $color13
            font_size = 12
            font_family = Victor Mono Bold Oblique
            position = 0, 150
            halign = center
            valign = bottom
        }

        input-field {
            monitor =
            size = 200, 40
            outline_thickness = 2
            dots_size = 0.2
            dots_spacing = 0.2
            dots_center = true
            outer_color = $color11
            inner_color = rgba(255, 255, 255, 0.1)
            capslock_color = rgb(255,255,255)
            font_color = $color13
            fade_on_empty = false
            font_family = Victor Mono Bold Oblique
            placeholder_text = <i><span foreground="##ffffff99">Type Password</span></i>
            hide_input = false
            position = 0, 50
            halign = center
            valign = bottom
        }

        label {
            monitor =
            text = cmd[update:60000] echo "<b> "$(uptime -p || $Scripts/UptimeNixOS.sh)" </b>"
            color = $color13
            font_size = 8
            font_family = Victor Mono Bold Oblique
            position = 0, 0
            halign = right
            valign = bottom
        }

        label {
            monitor =
            text = cmd[update:3600000] [ -f "$HOME/.cache/.weather_cache" ] && cat "$HOME/.cache/.weather_cache"
            color = $color13
            font_size = 8
            font_family = Victor Mono Bold Oblique
            position = 50, 0
            halign = left
            valign = bottom
        }
      '';
    };

    # ────────────────────────────────────────────────────────────────
    # Night light (replaces KDE Night Color)
    # ────────────────────────────────────────────────────────────────
    services.wlsunset = {
      enable = true;
      latitude = "52.5";
      longitude = "13.4";
    };

    # ────────────────────────────────────────────────────────────────
    # Kanshi — auto display profile switching (replaces nwg-displays)
    # Detects connected monitors and applies the right layout.
    # ────────────────────────────────────────────────────────────────
    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      settings = [
        # Laptop only
        {
          profile.name = "laptop";
          profile.outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@144.003Hz";
              position = "0,0";
              scale = 1.0;
            }
          ];
        }
        # Laptop + HDMI external (extend right)
        {
          profile.name = "laptop-hdmi";
          profile.outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@144.003Hz";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "HDMI-A-2";
              mode = "1920x1080@120Hz";
              position = "1920,0";
              scale = 1.0;
            }
          ];
        }
        # Laptop + DP external (extend right)
        {
          profile.name = "laptop-dp";
          profile.outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@144.003Hz";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "DP-3";
              mode = "1920x1080@143.855Hz";
              position = "1920,0";
              scale = 1.0;
            }
          ];
        }
        # Triple: laptop + HDMI + DP
        {
          profile.name = "triple";
          profile.outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@144.003Hz";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "HDMI-A-2";
              mode = "1920x1080@120Hz";
              position = "1920,0";
              scale = 1.0;
            }
            {
              criteria = "DP-3";
              mode = "1920x1080@143.855Hz";
              position = "3840,0";
              scale = 1.0;
            }
          ];
          profile.exec = [
            "notify-send 'Triple monitor' 'All three displays connected'"
          ];
        }
      ];
    };

    # ────────────────────────────────────────────────────────────────
    # KDE Connect — tray indicator for Hyprland session
    # Package + firewall rules already in modules/kde.nix
    # (programs.kdeconnect.enable = true). This just starts the indicator.
    # ────────────────────────────────────────────────────────────────
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    # ── Cursor theme ─────────────────────────────────────────────
    # Matches gtk.cursorTheme in modules/theme.nix (breeze_cursors).
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;
    };

    # ── Qt theming (needed outside KDE session) ──────────────────
    qt = {
      enable = true;
      platformTheme.name = "qtct";
    };

    # ── Systemd session vars ─────────────────────────────────────
    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };

    # ── Auto-mount drives (like KDE's Device Notifier) ──────────
    services.udiskie = {
      enable = true;
      tray = "auto";
      notify = true;
      automount = true;
    };

    # ── Waybar — powerline dark theme ─────────────────────────
    programs.waybar = {
      enable = true;
      systemd.enable = false; # started via exec-once
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        spacing = 0;
        margin-top = 3;
        margin-left = 6;
        margin-right = 6;

        modules-left = [
          "hyprland/workspaces"
          "custom/arrow-ws-end"
          "hyprland/window"
        ];
        modules-center = [
          "custom/arrow-clock-l"
          "clock"
          "custom/arrow-clock-r"
        ];
        modules-right = [
          "custom/arrow-r0"
          "tray"
          "custom/arrow-r1"
          "pulseaudio"
          "custom/arrow-r2"
          "network"
          "custom/arrow-r3"
          "battery"
          "custom/arrow-r4"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1"; "2" = "2"; "3" = "3"; "4" = "4"; "5" = "5";
            "6" = "6"; "7" = "7"; "8" = "8"; "9" = "9"; "10" = "0";
            urgent = "!"; default = " ";
          };
          on-click = "activate";
          all-outputs = false;
          sort-by-number = true;
          persistent-workspaces."*" = 5;
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 35;
          rewrite."" = " ";
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%a %d %b  %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          interval = 1;
        };

        pulseaudio = {
          format = "{icon}{volume}%";
          format-bluetooth = " {volume}%";
          format-muted = " mute";
          format-icons.default = [ " " " " " " ];
          format-icons.headphone = " ";
          on-click = "pavucontrol";
          on-click-right = "swayosd-client --output-volume mute-toggle";
          scroll-step = 2;
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ifname}";
          format-disconnected = " off";
          tooltip-format = "{ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
          max-length = 14;
        };

        battery = {
          format = "{icon}{capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [ " " " " " " " " " " ];
          states = { warning = 25; critical = 10; };
          tooltip-format = "{timeTo} | {power:.1f}W";
        };

        tray = { icon-size = 14; spacing = 6; };
        "custom/arrow-r0" = { format = ""; tooltip = false; };

        # Powerline arrows — each bridges two background colors
        # Left side: workspace bg → transparent
        "custom/arrow-ws-end" = { format = ""; tooltip = false; };
        # Clock wings
        "custom/arrow-clock-l" = { format = ""; tooltip = false; };
        "custom/arrow-clock-r" = { format = ""; tooltip = false; };
        # Right side segments (transparent → seg1 → seg2 → seg3 → accent)
        "custom/arrow-r1" = { format = ""; tooltip = false; };
        "custom/arrow-r2" = { format = ""; tooltip = false; };
        "custom/arrow-r3" = { format = ""; tooltip = false; };
        "custom/arrow-r4" = { format = ""; tooltip = false; };

        "custom/power" = {
          format = "";
          tooltip = false;
          on-click = "$HOME/.config/hypr/scripts/Wlogout.sh";
        };
      };

      style = let
        bg0 = "#0a0a0f";
        tray-bg = "#0f0f18";
        seg1 = "#141420";
        seg2 = "#1a1a2e";
        seg3 = "#222240";
        accent = "#0f5e53";   # dark muted teal
        ws-bg = "#111118";
        fg = "#b4befe";
        dim = "#45475a";
        arrow = "19px";
      in ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 11px;
          min-height: 0;
          border: none;
          border-radius: 0;
          padding: 0;
          margin: 0;
        }

        window#waybar {
          background: ${bg0};
          border-radius: 8px;
          color: ${fg};
        }

        /* ── Workspaces ── */
        #workspaces {
          background: ${ws-bg};
          border-radius: 8px 0 0 8px;
          margin-left: 2px;
        }
        #workspaces button {
          padding: 0 5px;
          color: ${dim};
          background: transparent;
          min-width: 16px;
          transition: all 0.15s ease;
        }
        #workspaces button.active {
          color: #00D3B8;
          font-weight: bold;
        }
        #workspaces button.urgent { color: #f38ba8; }
        #workspaces button:hover { color: ${fg}; }

        /* ── Left arrow ── */
        #custom-arrow-ws-end {
          font-size: ${arrow};
          color: ${ws-bg};
          background: transparent;
          padding: 0;
          margin: 0;
        }

        /* ── Window ── */
        #window {
          color: ${dim};
          padding: 0 10px;
          font-size: 10px;
        }

        /* ── Clock (center pill) ── */
        #custom-arrow-clock-l {
          font-size: ${arrow};
          color: ${accent};
          background: transparent;
          padding: 0;
          margin: 0;
        }
        #clock {
          background: ${accent};
          color: #e0e0e0;
          font-weight: bold;
          padding: 0 8px;
        }
        #custom-arrow-clock-r {
          font-size: ${arrow};
          color: ${accent};
          background: transparent;
          padding: 0;
          margin: 0;
        }

        /* ── Tray ── */
        #custom-arrow-r0 {
          font-size: ${arrow};
          color: ${tray-bg};
          background: transparent;
          padding: 0; margin: 0;
        }
        #tray {
          background: ${tray-bg};
          padding: 0 6px;
        }

        /* ── Right powerline arrows (◀ left-pointing) ── */
        /* For ◀: fg = right segment bg, bg = left segment bg */
        #custom-arrow-r1 {
          font-size: ${arrow};
          color: ${seg1};
          background: ${tray-bg};
          padding: 0; margin: 0;
        }
        #custom-arrow-r2 {
          font-size: ${arrow};
          color: ${seg2};
          background: ${seg1};
          padding: 0; margin: 0;
        }
        #custom-arrow-r3 {
          font-size: ${arrow};
          color: ${seg3};
          background: ${seg2};
          padding: 0; margin: 0;
        }
        #custom-arrow-r4 {
          font-size: ${arrow};
          color: ${accent};
          background: ${seg3};
          padding: 0; margin: 0;
        }

        /* ── Right modules ── */
        #pulseaudio {
          background: ${seg1};
          color: #cba6f7;
          padding: 0 8px;
        }
        #pulseaudio.muted { color: ${dim}; }

        #network {
          background: ${seg2};
          color: #00D3B8;
          padding: 0 8px;
        }
        #network.disconnected { color: ${dim}; }

        #battery {
          background: ${seg3};
          color: #a6e3a1;
          padding: 0 8px;
        }
        #battery.warning { color: #fab387; }
        #battery.critical { color: #f38ba8; }
        #battery.charging { color: ${accent}; }

        /* ── Power ── */
        #custom-power {
          background: ${accent};
          color: ${bg0};
          padding: 0 7px;
          border-radius: 0 8px 8px 0;
          margin-right: 2px;
        }
        #custom-power:hover { background: #00b89e; }

        tooltip {
          background: ${bg0};
          border: 1px solid rgba(0, 211, 184, 0.25);
          border-radius: 6px;
          color: ${fg};
        }
      '';
    };

    # ── Shell alias for hyprwinwrap ───────────────────────────────
    programs.zsh.initContent = ''
      live-wallpaper() {
        if [ -z "$1" ]; then
          echo "Usage: live-wallpaper <command>"
          echo "  live-wallpaper cava"
          echo "  live-wallpaper cmatrix"
          echo "  live-wallpaper btop"
          echo "  live-wallpaper 'mpv --loop video.mp4'"
          return 1
        fi
        # kill existing live wallpaper
        hyprctl clients -j | jq -r '.[] | select(.class=="hyprwinwrap") | .pid' | xargs -r kill
        # start new one
        kitty --class hyprwinwrap -e sh -c "$*" &
        disown
      }
    '';

    # ── First-boot setup (replaces initial-boot.sh) ──────────────
    # GTK theme/icons/cursor are handled declaratively by theme.nix
    # and home.pointerCursor above. This just creates directories.
    home.activation.hyprSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/hypr/wallpaper_effects"
      mkdir -p "$HOME/Pictures/Screenshots"
      mkdir -p "$HOME/.config/hypr/wallust"
      touch "$HOME/.config/hypr/wallust/wallust-hyprland.conf"
    '';

    # ── Scripts & animation presets ──────────────────────────────
    # These are shell scripts with no home-manager option equivalent.
    # xdg.configFile is the standard mechanism for custom files.
    # Using a whitelist to deploy only what's needed on NixOS.
    xdg.configFile =
      deployWhitelistedScripts (moduleDir + "/scripts") "scripts" coreScripts
      // deployWhitelistedScripts (moduleDir + "/UserScripts") "UserScripts" userScripts
      // deployFiles (moduleDir + "/animations") "animations"
      // {
        # ── Rofi — dark teal theme ──────────────────────────────
        "rofi/config.rasi".text = ''
          configuration {
            modi: "run,drun,window,filebrowser";
            show-icons: true;
            font: "JetBrainsMono Nerd Font 12";
            display-drun: "  Apps";
            display-run: "  Run";
            display-window: "  Windows";
            display-filebrowser: "  Files";
          }

          @theme "custom-dark"
        '';

        "rofi/themes/custom-dark.rasi".text = ''
          * {
            bg:       rgba(10, 10, 15, 0.92);
            bg-alt:   rgba(30, 30, 46, 0.95);
            fg:       #cdd6f4;
            fg-dim:   #585b70;
            accent:   #00D3B8;
            accent2:  #6C5CE7;
            urgent:   #f38ba8;
            border-colour: rgba(0, 211, 184, 0.3);
            selected: rgba(0, 211, 184, 0.15);

            font: "JetBrainsMono Nerd Font 12";
            border-radius: 12px;
          }

          window {
            width: 600px;
            transparency: "real";
            background-color: @bg;
            border: 1px solid;
            border-color: @border-colour;
            border-radius: 12px;
            padding: 0;
          }

          mainbox {
            background-color: transparent;
            children: [ inputbar, listview ];
            spacing: 0;
            padding: 0;
          }

          inputbar {
            background-color: @bg-alt;
            padding: 14px 16px;
            border-radius: 12px 12px 0 0;
            children: [ prompt, entry ];
            spacing: 10px;
          }

          prompt {
            background-color: transparent;
            text-color: @accent;
            font: "JetBrainsMono Nerd Font Bold 12";
          }

          entry {
            background-color: transparent;
            text-color: @fg;
            placeholder: "Search...";
            placeholder-color: @fg-dim;
          }

          listview {
            background-color: transparent;
            padding: 8px;
            columns: 1;
            lines: 8;
            spacing: 4px;
            scrollbar: false;
            fixed-height: true;
          }

          element {
            background-color: transparent;
            text-color: @fg;
            padding: 10px 14px;
            border-radius: 8px;
            spacing: 10px;
          }

          element selected.normal {
            background-color: @selected;
            text-color: @accent;
            border: 0 0 0 3px solid;
            border-color: @accent;
          }

          element normal.urgent, element alternate.urgent {
            text-color: @urgent;
          }

          element-icon {
            size: 22px;
            background-color: transparent;
          }

          element-text {
            background-color: transparent;
            text-color: inherit;
            vertical-align: 0.5;
          }
        '';

        # ── SwayNC — compact dark notifications ─────────────────
        "swaync/config.json".text = builtins.toJSON {
          "$schema" = "/etc/xdg/swaync/configSchema.json";
          positionX = "right";
          positionY = "top";
          control-center-margin-top = 8;
          control-center-margin-bottom = 8;
          control-center-margin-right = 8;
          notification-icon-size = 32;
          notification-body-image-height = 50;
          notification-body-image-width = 140;
          timeout = 6;
          timeout-low = 4;
          timeout-critical = 0;
          fit-to-screen = true;
          control-center-width = 280;
          notification-window-width = 260;
          keyboard-shortcuts = true;
          image-visibility = "when-available";
          transition-time = 200;
          hide-on-clear = false;
          hide-on-action = true;
          script-fail-notify = true;
          widgets = [ "title" "notifications" "mpris" "volume" "buttons-grid" ];
          widget-config = {
            title = {
              text = "Notifications";
              clear-all-button = true;
              button-text = "Clear";
            };
            volume = { label = " "; };
            mpris = {
              image-size = 48;
              blur = true;
            };
            buttons-grid = {
              actions = [
                { label = " "; command = "nm-connection-editor"; }
                { label = " "; command = "blueman-manager"; }
                { label = " "; command = "pavucontrol"; }
                { label = " "; command = "hyprctl dispatch dpms off"; }
              ];
            };
          };
        };

        "swaync/style.css".text = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
          }
          .notification-row {
            outline: none;
          }
          .notification {
            background: rgba(10, 10, 15, 0.92);
            border: 1px solid rgba(0, 211, 184, 0.15);
            border-radius: 8px;
            margin: 4px 0;
            padding: 0;
          }
          .notification-content {
            padding: 5px 8px;
          }
          .summary {
            color: #cdd6f4;
            font-weight: bold;
            font-size: 10px;
          }
          .body {
            color: #a6adc8;
            font-size: 9px;
          }
          .close-button {
            background: rgba(243, 139, 168, 0.15);
            color: #f38ba8;
            border-radius: 6px;
            padding: 2px 6px;
            margin: 6px;
          }
          .close-button:hover {
            background: rgba(243, 139, 168, 0.3);
          }
          .notification-action {
            background: rgba(0, 211, 184, 0.1);
            color: #00D3B8;
            border-radius: 6px;
            margin: 4px;
            padding: 4px 8px;
          }
          .notification-action:hover {
            background: rgba(0, 211, 184, 0.2);
          }
          .control-center {
            background: rgba(10, 10, 15, 0.95);
            border: 1px solid rgba(0, 211, 184, 0.15);
            border-radius: 10px;
            padding: 8px;
          }
          .control-center .notification {
            margin: 4px 0;
          }
          .widget-title {
            color: #00D3B8;
            font-weight: bold;
            padding: 6px 8px;
          }
          .widget-title button {
            background: rgba(243, 139, 168, 0.1);
            color: #f38ba8;
            border-radius: 6px;
            padding: 2px 10px;
          }
          .widget-volume {
            padding: 4px 8px;
          }
          .widget-buttons-grid {
            padding: 4px;
          }
          .widget-buttons-grid > flowbox > flowboxchild > button {
            background: rgba(0, 211, 184, 0.08);
            color: #b4befe;
            border-radius: 6px;
            padding: 6px;
            margin: 2px;
          }
          .widget-buttons-grid > flowbox > flowboxchild > button:hover {
            background: rgba(0, 211, 184, 0.18);
            color: #00D3B8;
          }
        '';
      };
  }; # end home-manager.users.user
}

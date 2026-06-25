{ config, lib, pkgs, ... }:

{

  # kwallet PAM auto-unlock at login: Quick Unlock stores its key in kwallet.
  # kwallet's Secret Service API is disabled below so KeePassXC remains
  # the sole freedesktop secrets provider, no other app will use kwallet.
  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.kscreenlocker.kwallet.enable = false;

  home-manager.users.user = {
    programs.keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        General = {
          ConfigVersion = 2;
          AutoSaveAfterEveryChange = true;
          AutoTypeDelay = 25;
          MinimizeAfterUnlock = true;
          RememberLastKeyFiles = true;
        };

        Browser.Enabled = true;

        FdoSecrets = {
          Enabled = true; # Enable Secret Service Integration
          ShowNotification = false;
        };

        GUI = {
          ShowTrayIcon = true;
          TrayIconAppearance = "monochrome-light";
          MinimizeOnStartup = true;
          MinimizeToTray = true;
          MinimizeOnClose = true;
          ApplicationTheme = "dark";
        };

        Security = {
          # DuckDuckGo fallback for favicons
          IconDownloadFallback = true;
          LockDatabaseIdle = false;
          LockDatabaseScreenLock = true;
          LockDatabaseSleep = false;
          EnableQuickUnlock = true;
        };
      };
    };

    # kwallet: enabled only as Quick Unlock backend.
    # - Disabled for all other apps (no prompts, no popups)
    # - Secret Service API disabled so KeePassXC is the sole secrets provider
    xdg.configFile."kwalletrc".text = ''
      [Wallet]
      Enabled=true
      First Use=false
      Close When Idle=false
      Close on Screensaver=false
      Prompt on Open=false

      [org.freedesktop.secrets]
      apiEnabled=false
    '';



    # KDE: do not lock screen on resume from suspend (lid open)
    # Screen only locks on explicit lock or idle timeout

    xdg.configFile."kscreenlockerrc" = {
      text = lib.mkForce ''
        [Greeter][Wallpaper][org.kde.image][General]
        Image=file:///nix/store/1n95gvf26ipr5d6vavyjzam7879h8qps-plasma-workspace-wallpapers-6.5.6/share/wallpapers/Path/
        PreviewImage=file:///nix/store/1n95gvf26ipr5d6vavyjzam7879h8qps-plasma-workspace-wallpapers-6.5.6/share/wallpapers/Path/
        SlidePaths=/nix/store/0c1311gy20x5sshmh7dkppxhsx3czwkj-breeze-6.5.6/share/wallpapers/,/run/current-system/sw/share/wallpapers/
        [Daemon]
        Autolock=false
        LockOnResume=false
      '';
      force = true;
    };
  };
}

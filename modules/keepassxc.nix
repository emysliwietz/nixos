{ config, lib, pkgs, ... }:

{

  # Disable kwallet (assuming Plasma)
  security.pam.services.sddm.kwallet.enable = false;
  security.pam.services.kscreenlocker.kwallet.enable = false;

  home-manager.users.user = {
    programs.keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        General.ConfigVersion = 2;

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

        Security.IconDownloadFallback = true; # DuckDuckGo fallback for favicons
      };
    };

    # Disable KWallet's own secret service so KeePassXC can take over
    xdg.configFile."kwalletrc".text = ''
      [Wallet]
        Enabled=true
        First Use=false

        [org.freedesktop.secrets]
        apiEnabled=false
    '';


    # KeePassXC config: enable secret service + auto-open + lock on sleep
    xdg.configFile."keepassxc/keepassxc.ini".text = ''
      [FdoSecrets]
      Enabled=true

      [General]
      AutoSaveAfterEveryChange=true
      AutoTypeDelay=25
      MinimizeAfterUnlock=true
      RememberLastKeyFiles=true

      [Security]
      LockDatabaseIdle=false
      LockDatabaseScreenLock=true
      LockDatabaseSleep=false
      EnableQuickUnlock=true
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
        LockOnResume=false
      '';
      force = true;
    }

  };
}

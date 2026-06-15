{ config, lib, pkgs, ... }:

{

  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.kscreenlocker.kwallet.enable = true;

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
        LockDatabaseIdle=true
        LockDatabaseIdleSeconds=600
        LockDatabaseScreenLock=true
    '';
  };
}

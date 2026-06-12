{
  config,
  pkgs,
  ...
}:

{
  home-manager.users.user {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc ];
    languagePacks = [
      "en"
      "de"
      "tg"
      "nl"
      "la"
    ];

    policies = {
      HardwareAcceleration = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DefaultDownloadDirectory = "/home/user/downloads";
    };

    profiles.default = {
      id = 0;
      isDefault = true;

      search = {
        default = "ddg";
        force = true; # prevents Firefox from overriding it on updates
      };

      settings = {
        # enable compact mode (hidden option since Firefox 89)
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
        "full-screen-api.ignore-widgets" = true;
      };

    };
  };
};
}

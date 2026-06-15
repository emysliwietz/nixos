# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/firefox.nix
    ./modules/shell.nix
    ./modules/nvidia.nix
    ./modules/kde.nix
    ./modules/emacs.nix
    ./modules/thunar.nix
    ./modules/dolphin.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    "user"
  ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.configurationLimit = 30;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [
    "snd-aloop"
  ];

  networking.hostName = "astaroth"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;


  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };



  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.kscreenlocker.kwallet.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "Egidius";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      teams-for-linux
      qbittorrent
    ];
  };

  home-manager.useGlobalPkgs = true; # uses system pkgs, avoids a second nixpkgs eval
  home-manager.useUserPackages = true; # installs packages to /etc/profiles/per-user/...

  home-manager.users.user =
    { pkgs, ... }:
    {

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


      programs.neovim = {
        enable = true;
        defaultEditor = false;
        viAlias = true;
        vimAlias = true;
        extraLuaConfig = ''
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.clipboard = "unnamedplus"
        '';
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

      programs.zathura = {
        enable = true;
        mappings = {
          i = "recolor";
          n = "navigate next";
          p = "navigate previous";
        };
        options = {
          selection-clipboard = "clipboard";
          recolor-keephue = "true";
          recolor = "true";
          guioptions = "";
          window-title-home-tilde = "true";
          statusbar-basename = "true";
          adjust-open = "best-fit";
          scroll-page-aware = "true";
        };
      };

      gtk = {
        enable = true;
        theme = {
          package = pkgs.kdePackages.breeze-gtk;
          name = "Breeze-Dark";
        };

        font = {
          name = "SauceCodePro Semibold";
          size = 10;
        };

        cursorTheme = {
          name = "breeze_cursors";
          size = 24;
        };

        iconTheme = {
          package = pkgs.flat-remix-icon-theme;
          name = "Flat-Remix-Green-Dark";
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      programs.git = {
        enable = true;
        settings.user = {
          name = "Egidius";
          email = "git@sermak.xyz";
        };
        settings = {
          credential.helper = "store"; # caches in ~/.git-credentials
        };
      };

  # Utility function to install a package with an arbitrary name
  # In environment.systemPackages, just put i.e. (renamePackage pkgs.caprine "caprine" "facebook-messenger")
   renamePackage = pkg: oldName: newName:
    pkgs.runCommand newName {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin $out/share

      makeWrapper ${pkg}/bin/${oldName} $out/bin/${newName}

      if [ -d ${pkg}/share/applications ]; then
        cp -r ${pkg}/share/applications $out/share/applications
        chmod -R +w $out/share/applications
        substituteInPlace $out/share/applications/*.desktop \
          --replace-fail "Exec=${oldName}" "Exec=${newName}"
      fi

      for dir in ${pkg}/share/*; do
        name=$(basename "$dir")
        [ "$name" = "applications" ] && continue
        ln -s "$dir" "$out/share/$name"
      done
    '';



      home.packages = with pkgs; [
        kdePackages.breeze-gtk

        (writeShellScriptBin "mpv" ''
          exec nvidia-offload ${mpv}/bin/mpv "$@"
        '')

        (writeShellScriptBin "mpv-cpu" ''
          exec ${mpv}/bin/mpv "$@"
        '')

        devenv
	    claude-code

        (pkgs.runCommand "rd" {} ''
          mkdir -p $out/bin
          ln -s /home/user/dox/projects/dictionary/dict-rust/target/release/dict-rust $out/bin/rd
        '')

        # facebook messenger
        (renamePackage caprine "caprine" "facebook-messenger")

        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
	    nerd-fonts.sauce-code-pro
        symbola

        sqlite

        (python3.withPackages (python-pkgs: with python-pkgs; [
	      pandas
	      requests
	      numpy
	      snowballstemmer # requirement for emacs minor-mode
	    ]))

        signal-desktop

        koreader
      ];

      programs.htop = {
        enable = true;
        settings = {
          tree-view = 1;
          enable_mouse = 1;
          show_cpu_usage = 1;
          show_cpu_frequency = 1;
          show_cpu_temperature = 1;
          show_program_path = 1;
        };
      };

      programs.bash.enable = true;

      fonts.fontconfig.enable = true;

      xdg.configFile."autostart/signal-desktop.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Signal
        Exec=${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --no-sandbox
        X-GNOME-Autostart-enabled=true
      '';


      xdg.autostart.enable = true; # Enable creation of XDG autostart entries.

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

      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.

    };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = false;
    plugins = with pkgs.obs-studio-plugins; [
    ];
  };

  programs.hyprland.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    ffmpeg
    killall
    unzip
    mpv
    libreoffice-qt6
    wl-clipboard
    neovim
    nmap
    libnotify
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  services.syncthing = {
    enable = true;
    user = "user";
    openDefaultPorts = true;
    settings = {
      devices = {
        "f8" = {
          id = "RKNFHYR-NIGI2ND-75B5MOJ-MFWWNOR-GCKKCMO-Y2BIJHC-4IHJTUB-MC7CBAB";
        };
        "tolino" = {
          id = "6ERDEST-MHMOBE4-ZXM5RT6-TWDMCZP-F6X4ENU-N645IWI-AUMPURJ-YNGAHAV";
        };
      };
      folders = {
        "books" = {
          path = "/home/user/dox/books";
          devices = [
            "f8"
            "tolino"
          ];
        };
      };
    };
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };

  environment.etc."gitconfig".text = ''
    [user]
      name = "Egidius"
      email = "git@sermak.xyz"
    [credential]
      helper = store
  '';

  # List of hardware to enable
  hardware.bluetooth.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

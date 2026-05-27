# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };

    # Tell Xorg/Wayland to use the nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for Wayland
    modesetting.enable = true;

    # Power management — lets dGPU fully power off when idle
    powerManagement.enable = true;
    powerManagement.finegrained = true;  # requires offload mode (set below)

    # Quadro P500 is Pascal — open modules require Turing+, so keep this false
    open = false;

    # Enables the nvidia-settings GUI
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;  # adds `nvidia-offload` helper command
      };

      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  # Enables D-Bus service that KDE Plasma uses for per-app GPU selection
  services.switcherooControl.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    discover
    dolphin
    elisa
    okular
  ];

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
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
	teams-for-linux
	droidcam
	qbittorrent

    ];
  };

  home-manager.useGlobalPkgs = true;    # uses system pkgs, avoids a second nixpkgs eval
  home-manager.useUserPackages = true;  # installs packages to /etc/profiles/per-user/...
 
  home-manager.users.user = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild = "sudo git -C /etc/nixos add . && sudo git -C /etc/nixos commit -m \"$(date '+%F %T')\" && sudo git -C /etc/nixos push || true && sudo nixos-rebuild switch --flake /etc/nixos";
	vim = "nvim";
	sudo = "sudo ";
	".." = "cd ..";
	"..." = "cd ../..";
	"...." = "cd ../../..";
      };
    };

  home.file.".config/Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu></submenu>
        <unique-id>1234567890123456-1</unique-id>
        <command>xfce4-terminal --working-directory %f</command>
        <description>Open terminal in this directory</description>
        <patterns>*</patterns>
        <directories/>
      </action>

      <action>
        <icon>application-pdf</icon>
        <name>PPTX to PDF</name>
        <submenu></submenu>
        <unique-id>1234567890123456-2</unique-id>
        <command>bash -c 'libreoffice --headless --convert-to pdf "%f"'</command>
        <description>Convert PPTX to PDF</description>
        <patterns>*.pptx;*.PPTX</patterns>
        <files/>
      </action>
    </actions>
  '';

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

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };

  
  programs.git = {
  	enable = true;
	settings.user = {
		name = "Egidius";	
		email = "git@sermak.xyz";
	};
  };

  home.sessionPath = [
  	  "$HOME/.config/emacs/bin"
  ];

    home.packages = with pkgs; [ 
  (writeShellScriptBin "mpv" ''
    exec nvidia-offload ${mpv}/bin/mpv "$@"
  '')

  (writeShellScriptBin "mpv-cpu" ''
    exec ${mpv}/bin/mpv "$@"
  '')

  (writeShellScriptBin "facebook-messenger" ''
    exec ${caprine}/bin/caprine "$@"
  '')

  (writeShellScriptBin "e" ''
  	    exec emacsclient -c -a "" "$@"
  '')




  	((emacsPackagesFor emacs).treesit-grammars.with-grammars (grammars: with grammars; [
    		tree-sitter-nix
    		tree-sitter-python
    		tree-sitter-bash
		tree-sitter-rust
		tree-sitter-markdown
		tree-sitter-markdown-inline
		tree-sitter-javascript
    		# etc
  	]))

  # facebook messenger
  caprine

  # :checkers spell
  aspell
  aspellDicts.en

  ripgrep
  fd

  nerd-fonts.jetbrains-mono
  nerd-fonts.symbols-only
  symbola

  cmake
  gnumake

  gore
  jdk
  pandoc
  pipenv
  python3Packages.nose2
  poetry

  isync
  mu

  sqlite

  # :tools direnv
  direnv

  # :tools lookup
  sqlite

  # :tools lsp
  nodejs

  # :lang cc
  clang-tools  # provides clang-format

  # :lang nix
  nixfmt-rfc-style

  # :lang org
  graphviz    # provides dot
  gnuplot
  maim        # screenshots

  # :lang sh
  shfmt
  shellcheck

  # :lang markdown
  grip

  # :lang python
  python3
  black
  python3Packages.pyflakes
  python3Packages.isort
  python3Packages.pytest

  # :lang rust
  rust-analyzer
  cargo
  rustc

  # :lang go
  gopls
  gomodifytags
  gotests

  # :tools docker
  dockfmt

  # :app rss
  yt-dlp

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


    programs.firefox = {
  enable = true;
  nativeMessagingHosts = [ pkgs.keepassxc ];
  languagePacks = [ "en" "de" ];

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


  # Install firefox.
  programs.zsh.enable = true;
  programs.kdeconnect.enable = true;

# needed for droidcam bug
nixpkgs.overlays = [
  (final: prev: {
    obs-studio-plugins = prev.obs-studio-plugins // {
      droidcam-obs = (prev.obs-studio-plugins.droidcam-obs.override {
        ffmpeg_7 = prev.ffmpeg;
      }).overrideAttrs (_: {
        version = "2.4.2-unstable-2025-10-14";
        src = prev.fetchFromGitHub {
          owner = "dev47apps";
          repo = "droidcam-obs-plugin";
          rev = "161cb95b8dc5fe77185e52a9783dc45c6d137165";
          sha256 = "sha256-3GClykaJjjmasEnSVGU5jnz+xoznaSYTxBz7jkhj0m4=";
        };
      });
    };
  })
];

  programs.obs-studio = {
  	enable = true;
    	enableVirtualCamera = true;
    	plugins = with pkgs.obs-studio-plugins; [
      		droidcam-obs
    	];
  };
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true; # needed to keep thunar config changes without xfce


  programs.hyprland.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	wget
	kitty
	ffmpeg
	killall
	unzip
	mpv
	zathura
	libreoffice-qt6
	wl-clipboard
	neovim
	nmap
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

  services.tumbler.enable = true; # Thumbnails in thunar
  services.gvfs.enable = true; # Mount, trash in thunar

services.syncthing = {
  enable = true;
  user = "user";
  openDefaultPorts = true;
  settings = {
    devices = {
      "f8" = { id = "RKNFHYR-NIGI2ND-75B5MOJ-MFWWNOR-GCKKCMO-Y2BIJHC-4IHJTUB-MC7CBAB"; };
      "tolino" = { id = "6ERDEST-MHMOBE4-ZXM5RT6-TWDMCZP-F6X4ENU-N645IWI-AUMPURJ-YNGAHAV"; };
    };
    folders = {
      "books" = {
        path = "/home/user/dox/books";
        devices = [ "f8" "tolino" ];
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

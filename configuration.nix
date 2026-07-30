# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ] ++ (
    # Auto-import every .nix file under ./modules/
    let dir = ./modules; in
    map (f: dir + "/${f}")
      (builtins.filter (f: builtins.match ".*\\.nix" f != null)
        (builtins.attrNames (builtins.readDir dir)))
  );

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    "user"
  ];

  networking.hostName = "astaroth"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;


  services.qbittorrent = {
    enable = true;
    openFirewall = true;
  };




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


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
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
  home-manager.backupCommand = "bash -c 'rm -f \"$1.hm-backup\" && mv \"$1\" \"$1.hm-backup\"' --";

  home-manager.users.user =
    { pkgs, ... }:
    {
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

	jellyfin-media-player

        devenv

        (pkgs.runCommand "rd" {} ''
          mkdir -p $out/bin
          ln -s /home/user/dox/projects/dictionary/dict-rust/target/release/dict-rust $out/bin/rd
        '')

        # facebook messenger
        caprine


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


      xdg.configFile."autostart/signal-desktop.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Signal
        Exec=${pkgs.signal-desktop}/bin/signal-desktop --start-in-tray --no-sandbox --password-store=gnome-libsecret
        X-GNOME-Autostart-enabled=true
      '';


      xdg.autostart.enable = true; # Enable creation of XDG autostart entries.


      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.

    };

      programs.ausweisapp = {
 	 enable = true;
  	openFirewall = true;
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


  # List of hardware to enable
  hardware.bluetooth.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}

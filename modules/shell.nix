{
  config,
  pkgs,
  ...
}:

{
  users.users.user = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.users.user = {
    home.sessionPath = [
    	"/home/user/.local/bin"
	"/home/user/dox/projects/bible/bin"
    ];

    programs.zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        ignoreAllDups = true;
      };

      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
        "AUTO_CD"
      ];

      shellAliases = {
        vim = "nvim";
        sudo = "sudo ";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };

      initContent = ''
        caffeine() {
	    systemd-inhibit --what=idle:sleep --why="Keep screen awake" sleep infinity
	}

        take() {
            mkdir -p "$1" && cd "$1"
        }

        rebuild() {
            sudo git -C /etc/nixos add .
            sudo git -C /etc/nixos commit -m "$(date '+%F %T')" || true
            sudo git -C /etc/nixos push || true
            sudo nixos-rebuild switch --flake /etc/nixos
        }

	update() {
	    sudo nix flake update --flake /etc/nixos
	    rebuild
	}

        nix-clean() {
            sudo nix-collect-garbage --delete-older-than 14d
            sudo nix-store --gc
            sudo nix-store --optimise
        }
      '';
    };
  };
}

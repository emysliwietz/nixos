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
        take() {
            mkdir -p "$1" && cd "$1"
        }

        rebuild() {
            sudo git -C /etc/nixos add .
            sudo git -C /etc/nixos commit -m "$(date '+%F %T')" || true
            sudo git -C /etc/nixos push || true
            sudo nixos-rebuild switch --flake /etc/nixos
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

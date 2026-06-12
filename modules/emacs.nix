{ config, pkgs, ... }:

{
  home-manager.users.user = {

    programs.emacs = {
      enable = true;

      # pgtk for Wayland support
      package = pkgs.emacs-pgtk;

      # Pre-install tree-sitter grammars
      extrapackages = epkgs: [
        (epkgs.treesit-grammars.with-grammars (
          grammars: with grammars; [
            tree-sitter-nix
            tree-sitter-python
            tree-sitter-bash
            tree-sitter-rust
            tree-sitter-markdown
            tree-sitter-markdown-inline
            tree-sitter-javascript
            tree-sitter-jsdoc
          ]
        ))
      ];
    };

    # Shorthand that launches tui in terminal and gui as shortcut
    home.packages = with pkgs; [
      (writeShellScriptBin "e" ''
        if [ -t 0 ]; then
            exec emacsclient -nw -a "" "$@"
          else
            exec emacsclient -c -a "" "$@"
          fi
      '')
    ];

    # Add doom bin to path
    home.sessionPath = [
      "$HOME/.config/emacs/bin"
    ];

    # Dependencies for doom modules
    home.packages = with pkgs; [
      # general
      ripgrep
      fd

      # :checkers spell
      aspell
      aspellDicts.en

      # :tools direnv
      direnv

      # :tools lookup
      sqlite

      # :tools lsp
      nodejs

      # :lang cc
      clang-tools # provides clang-format
      cmake
      gnumake

      # :lang nix
      nixfmt-rfc-style

      # :lang org
      graphviz # provides dot
      gnuplot
      maim # screenshots

      # :lang sh
      shfmt
      shellcheck

      # :lang markdown
      grip

      # :lang python
      black
      python3Packages.pyflakes
      python3Packages.isort
      python3Packages.pytest
      gore
      jdk
      pandoc
      pipenv
      python3Packages.nose2
      poetry

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

      # :email
      isync
      mu

      # lsp
      nixd ## nix lsp

    ];
  };
}

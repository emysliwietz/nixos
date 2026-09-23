{ config, pkgs, lib, ... }:

let
  # Service menu with Icon / submenu grouping / URL-count gating.
  # `exec` receives the selected files as "$@" via `sh -c '…' _ %F`, so
  # filenames with spaces survive (a plain `for f in %F` does not).
  mkMenu =
    { name, label, mimes, exec, icon ? "", submenu ? "Convert", extra ? "" }:
    let
      lines = builtins.filter (l: l != null) [
        "[Desktop Entry]"
        "Type=Service"
        "ServiceTypes=KonqPopupMenu/Plugin"
        "MimeType=${lib.concatStringsSep ";" mimes};"
        "Actions=${name}"
        (if submenu == "" then null else "X-KDE-Submenu=${submenu}")
        (if extra == "" then null else extra)
        ""
        "[Desktop Action ${name}]"
        "Name=${label}"
        (if icon == "" then null else "Icon=${icon}")
        "Exec=sh -c '${exec}' _ %F"
      ];
    in {
      ".local/share/kio/servicemenus/${name}.desktop".text =
        lib.concatStringsSep "\n" lines + "\n";
    };

  # ── mimetype groups (taken from shared-mime-info on this machine) ──
  presentations = [
    "application/vnd.ms-powerpoint"
    "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
    "application/vnd.oasis.opendocument.presentation"
  ];
  documents = [
    "application/msword"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "application/vnd.oasis.opendocument.text"
    "application/rtf"
  ];
  spreadsheets = [
    "application/vnd.ms-excel"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "application/vnd.oasis.opendocument.spreadsheet"
  ];
  office = presentations ++ documents ++ spreadsheets;
  images = [ "image/jpeg" "image/png" "image/webp" "image/tiff" ];
  videos = [ "video/mp4" "video/x-matroska" "video/quicktime" "video/webm" "video/x-msvideo" ];
  ebooks = [
    "application/epub+zip"
    "application/x-mobipocket-ebook"
    "application/vnd.amazon.mobi8-ebook"
    "application/vnd.comicbook+zip"
    "application/x-fictionbook+xml"
  ];

in
{
  home-manager.users.user.home.packages = with pkgs; [
    poppler-utils   # pdftotext, pdftoppm, pdfunite, pdfinfo
    p7zip
    calibre         # ebook-convert -> Tolino / KOReader
    exiftool
  ];

  home-manager.users.user.home.file = lib.mkMerge [

    # ── Merge a selection into ONE pdf (only shows with 2+ selected) ──
    (mkMenu {
      name = "office-merge-pdf"; label = "Merge into one PDF";
      mimes = office ++ [ "application/pdf" ]; icon = "document-import";
      extra = "X-KDE-MinNumberOfUrls=2";
      exec = ''d="$(dirname "$1")"; t="$(mktemp -d)"; i=0;  for f in "$@"; do i=$((i+1)); case "$f" in *.pdf) cp "$f" "$t/$i.pdf";;  *) libreoffice --headless -env:UserInstallation=file:///tmp/lo-conv-$$ --convert-to pdf  --outdir "$t" "$f" >/dev/null 2>&1; mv "$t/$(basename "''${f%.*}").pdf" "$t/$i.pdf" 2>/dev/null;; esac; done; pdfunite "$t"/*.pdf "$d/merged.pdf"; rm -rf "$t"'';
    })

    # ── PDF: shrink, extract text, render pages ──
    (mkMenu {
      name = "pdf-compress"; label = "Compress PDF"; mimes = [ "application/pdf" ];
      icon = "application-pdf";
      exec = ''for f in "$@"; do gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dPDFSETTINGS=/ebook  -dNOPAUSE -dBATCH -dQUIET -sOutputFile="''${f%.*}-small.pdf" "$f"; done'';
    })
    (mkMenu {
      name = "pdf-to-text"; label = "Extract text"; mimes = [ "application/pdf" ];
      icon = "text-plain";
      exec = ''for f in "$@"; do pdftotext -layout "$f" "''${f%.*}.txt"; done'';
    })
    (mkMenu {
      name = "pdf-to-images"; label = "Render pages to PNG"; mimes = [ "application/pdf" ];
      icon = "image-png";
      exec = ''for f in "$@"; do pdftoppm -png -r 150 "$f" "''${f%.*}-page"; done'';
    })

    # ── Images ──
    (mkMenu {
      name = "image-to-webp"; label = "Convert to WebP"; mimes = images; icon = "image-webp";
      exec = ''for f in "$@"; do magick "$f" -quality 82 "''${f%.*}.webp"; done'';
    })
    (mkMenu {
      name = "image-resize-1600"; label = "Resize to max 1600px"; mimes = images; icon = "transform-scale";
      exec = ''for f in "$@"; do magick "$f" -resize "1600x1600>" "''${f%.*}-1600.''${f##*.}"; done'';
    })
    (mkMenu {
      name = "image-strip-exif"; label = "Strip metadata (in place)"; mimes = images; icon = "edit-clear";
      exec = ''exiftool -all= -overwrite_original "$@" >/dev/null 2>&1'';
    })

    # ── Video ──
    (mkMenu {
      name = "video-extract-audio"; label = "Extract audio (Opus)"; mimes = videos; icon = "audio-x-generic";
      exec = ''for f in "$@"; do ffmpeg -nostdin -i "$f" -vn -c:a libopus -b:a 128k "''${f%.*}.opus" </dev/null >/dev/null 2>&1; done'';
    })
    (mkMenu {
      name = "video-to-gif"; label = "Convert to GIF (10fps, 640px)"; mimes = videos; icon = "image-gif";
      exec = ''for f in "$@"; do ffmpeg -nostdin -i "$f" -vf "fps=10,scale=640:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse"  -loop 0 "''${f%.*}.gif" </dev/null >/dev/null 2>&1; done'';
    })

    # ── Ebooks ──
    (mkMenu {
      name = "ebook-to-epub"; label = "Convert to EPUB"; mimes = ebooks ++ [ "application/pdf" ];
      icon = "application-epub+zip";
      exec = ''for f in "$@"; do ebook-convert "$f" "''${f%.*}.epub" >/dev/null 2>&1; done'';
    })

    # ── Markdown via pandoc ──
    (mkMenu {
      name = "markdown-to-pdf"; label = "Convert to PDF"; mimes = [ "text/markdown" "text/x-markdown" ];
      icon = "application-pdf";
      exec = ''for f in "$@"; do pandoc "$f" -o "''${f%.*}.pdf"; done'';
    })

    # ── Anything ──
    (mkMenu {
      name = "copy-path"; label = "Copy full path"; mimes = [ "all/all" ]; icon = "edit-copy"; submenu = "";
      exec = ''for f in "$@"; do echo "$f"; done | wl-copy'';
    })
    (mkMenu {
      name = "sha256"; label = "SHA-256 to clipboard"; mimes = [ "all/allfiles" ]; icon = "security-high";
      exec = ''sha256sum "$@" | wl-copy'';
    })
  ];
}

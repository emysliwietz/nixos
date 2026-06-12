{ config, pkgs, lib, ... }:

  let
  # Helper to create service menu entries
  mkServiceMenu = name: description: mimeTypes: exec: {
    ".local/share/kservices5/ServiceMenus/${name}.desktop".text = ''
      [Desktop Entry]
      Type=Service
      ServiceTypes=KonqPopupMenu/Plugin
      MimeType=${lib.concatStringsSep ";" mimeTypes};
      Actions=${name}
      X-KDE-Priority=TopLevel

      [Desktop Action ${name}]
      Name=${description}
      Exec=${exec}
    '';
  };

  in
  {
  # Required packages
  home-manager.users.user.home.packages = with pkgs; [
    ffmpeg
    ghostscript
    imagemagick
    yt-dlp
    libreoffice
    (python3.withPackages (ps: with ps; [ rembg ]))
  ];

  # Service menu files
  home-manager.users.user.home.file = lib.mkMerge [
    (mkServiceMenu "convert-video" "Convert Video (GPU)"
      [ "video/mp4" "video/x-matroska" "video/quicktime" ]
      "sh -c 'for f in %F; do ffmpeg -i \"$f\" -c:v hevc_nvenc -c:a aac \"\${f%.*}.mp4\"; done'")

    (mkServiceMenu "convert-video" "Convert Video (ffmpeg)"
      [ "video/mp4" "video/x-matroska" "video/quicktime" ]
      "sh -c 'for f in %F; do ffmpeg -i \"$f\" -c:v hevc_nvenc -c:a aac \"\${f%.*}.mp4\"; done'")

    (mkServiceMenu "remove-background" "Remove Background"
      [ "image/jpeg" "image/png" "image/webp" ]
      "sh -c 'for f in %F; do python3 -m rembg i \"$f\" \"\${f%.*}-nobg.png\"; done'")

    (mkServiceMenu "rotate-image" "Rotate Image 90°"
      [ "image/jpeg" "image/png" "image/webp" ]
      "sh -c 'for f in %F; do convert \"$f\" -rotate 90 \"$f\"; done'")

    (mkServiceMenu "office-to-pdf" "Convert to PDF"
      [
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ]
      "sh -c 'for f in %F; do libreoffice --headless --convert-to pdf \"$f\" --outdir \"$(dirname \"$f\")\"; done'")

    (mkServiceMenu "images-to-pdf" "Combine Images to PDF"
      [ "image/jpeg" "image/png" ]
      "sh -c 'convert %F \"$(dirname %f)/combined.pdf\"'")

    (mkServiceMenu "images-to-gif" "Create Animated GIF"
      [ "image/jpeg" "image/png" ]
      "sh -c 'convert -delay 100 %F \"$(dirname %f)/animation.gif\"'")

    (mkServiceMenu "download-video" "Download Video (yt-dlp)"
      [ ]
      "yt-dlp -o \"%(title)s.%(ext)s\" \"$(wl-paste)\"")
  ];
};

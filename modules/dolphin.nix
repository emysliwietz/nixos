{ config, pkgs, lib, ... }:

  let
  # Helper to create service menu entries
  mkServiceMenu = name: description: mimeTypes: exec: {
    ".local/share/kio/servicemenus/${name}.desktop".text = ''
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
    rembg
  ];

  # Service menu files
  home-manager.users.user.home.file = lib.mkMerge [
    (mkServiceMenu "convert-video-gpu" "Convert Video (GPU)"
      [ "video/mp4" "video/x-matroska" "video/quicktime" ]
      "sh -c 'for f in %F; do ffmpeg -i \"$f\" -c:v hevc_nvenc -c:a aac \"\${f%.*}.mp4\"; done'")

    (mkServiceMenu "convert-video" "Convert Video (ffmpeg)"
      [ "video/mp4" "video/x-matroska" "video/quicktime" ]
      "sh -c 'for f in %F; do ffmpeg -i \"$f\" -c:v libx265 -c:a aac \"\${f%.*}.mp4\"; done'")

    (mkServiceMenu "remove-background" "Remove Background"
      [ "image/jpeg" "image/png" "image/webp" ]
      "sh -c 'for f in \"$@\"; do rembg i \"$f\" \"\${f%.*}-nobg.png\"; done' _ %F")

    (mkServiceMenu "rotate-image" "Rotate Image 90°"
      [ "image/jpeg" "image/png" "image/webp" ]
      "sh -c 'for f in %F; do convert \"$f\" -rotate 90 \"$f\"; done'")

    (mkServiceMenu "office-to-pdf" "Convert to PDF"
      [
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.ms-powerpoint"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
        "application/vnd.oasis.opendocument.presentation"
        "application/vnd.oasis.opendocument.text"
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/rtf"
      ]
      "sh -c 'for f in \"$@\"; do libreoffice --headless -env:UserInstallation=file:///tmp/lo-conv-$$ --convert-to pdf --outdir \"$(dirname \"$f\")\" \"$f\" >/dev/null 2>&1; done' _ %F")

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
}

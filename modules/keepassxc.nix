{ config, lib, pkgs, ... }:

let
  # Auto-unlock at login without a keyring:
  # the DB password is stored encrypted with the login password
  # (~/.local/share/keepassxc-unlock/dbpass.enc, made by keepassxc-unlock-setup).
  # At SDDM login, pam_exec decrypts it into tmpfs; the autostart feeds it to
  # keepassxc --pw-stdin and wipes it. A wrong login password decrypts nothing.
  openssl = "${pkgs.openssl.bin}/bin/openssl";
  encArgs = "enc -aes-256-cbc -pbkdf2 -iter 600000";
  runDir = "/run/keepassxc-unlock";
  blobPath = ".local/share/keepassxc-unlock/dbpass.enc";
  db = "$HOME/dox/passwords/Passwords.kdbx";
  keyFile = "$HOME/dox/passwords/pwd";

  # Runs as root from pam_exec; login password arrives NUL-terminated on stdin.
  pamHook = pkgs.writeShellScript "keepassxc-unlock-pam" ''
    set -u
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.getent pkgs.util-linux ]}
    [ "''${PAM_TYPE:-}" = auth ] || exit 0
    user=''${PAM_USER:-}
    entry=$(getent passwd "$user") || exit 0
    uid=$(echo "$entry" | cut -d: -f3)
    gid=$(echo "$entry" | cut -d: -f4)
    home=$(echo "$entry" | cut -d: -f6)
    blob="$home/${blobPath}"
    [ -f "$blob" ] || exit 0
    IFS= read -r -d "" pw || true
    umask 077
    tmp=$(mktemp ${runDir}/.XXXXXX) || exit 0
    chown "$uid:$gid" "$tmp"
    # Decrypt as the user, so root never opens a user-controlled path.
    if printf '%s' "$pw" | setpriv --reuid="$uid" --regid="$gid" --clear-groups \
         ${openssl} ${encArgs} -d -pass stdin -in "$blob" >"$tmp" 2>/dev/null; then
      mv -f "$tmp" "${runDir}/$user"
    else
      rm -f "$tmp"
    fi
    exit 0
  '';

  autostartScript = pkgs.writeShellScriptBin "keepassxc-autounlock" ''
    f="${runDir}/$(id -un)"
    running() {
      ${pkgs.procps}/bin/pgrep -u "$(id -u)" -f '/bin/\.?keepassxc(-wrapped)?( |$)' >/dev/null
    }
    # A running instance would only receive the filename, not the password,
    # so quit it (same as tray -> Quit) before handing over the password.
    if [ -s "$f" ] && running; then
      ${pkgs.systemd}/bin/busctl --user call org.keepassxc.KeePassXC.MainWindow \
        /keepassxc org.keepassxc.KeePassXC.MainWindow appExit 2>/dev/null
      for _ in $(seq 50); do running || break; sleep 0.2; done
      if running; then
        echo "KeePassXC didn't quit; leaving the password for a later launch." >&2
        exit 1
      fi
    fi
    if [ -s "$f" ]; then
      pw=$(cat "$f")
      : >"$f"
      printf '%s\n' "$pw" | ${pkgs.keepassxc}/bin/keepassxc \
        --pw-stdin --keyfile "${keyFile}" "${db}"
    else
      exec ${pkgs.keepassxc}/bin/keepassxc
    fi
  '';

  setupScript = pkgs.writeShellScriptBin "keepassxc-unlock-setup" ''
    set -eu
    ask() { # ask VAR PROMPT: read twice without echo, require a match
      local a b
      while :; do
        read -rsp "$2: " a; echo
        read -rsp "$2 (again): " b; echo
        [ "$a" = "$b" ] && break
        echo "Didn't match, try again."
      done
      printf -v "$1" '%s' "$a"
    }
    ask dbpw "KeePassXC database password"
    if ! printf '%s\n' "$dbpw" | ${pkgs.keepassxc}/bin/keepassxc-cli db-info -q \
         -k "${keyFile}" "${db}" >/dev/null 2>&1; then
      echo "That password doesn't open ${db}." >&2; exit 1
    fi
    ask lp "Login password"
    mkdir -p "$HOME/$(dirname ${blobPath})"
    umask 077
    printf '%s' "$dbpw" | ${openssl} ${encArgs} -salt -pass fd:3 \
      -out "$HOME/${blobPath}" 3< <(printf '%s' "$lp")
    echo "Saved. Re-run this whenever you change your login password."
  '';
in
{
  systemd.tmpfiles.rules = [ "d ${runDir} 0755 root root -" ];

  # After the login substack (order 10100), so PAM already holds the password.
  security.pam.services.sddm.rules.auth.keepassxc-unlock = {
    order = 10200;
    control = "optional";
    modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
    args = [ "expose_authtok" "quiet" "${pamHook}" ];
  };

  # Note: Quick Unlock does not use kwallet; its key lives only in KeePassXC's
  # memory (polkit on Linux), so it only helps re-unlock after a screen lock.
  # kwallet's Secret Service API is disabled below so KeePassXC remains
  # the sole freedesktop secrets provider, no other app will use kwallet.
  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.kscreenlocker.kwallet.enable = false;

  home-manager.users.user = {
    home.packages = [ setupScript autostartScript ];

    xdg.autostart.entries = [
      "${pkgs.makeDesktopItem {
        name = "keepassxc-autounlock";
        desktopName = "KeePassXC (auto-unlock)";
        exec = "${autostartScript}/bin/keepassxc-autounlock";
        icon = "keepassxc";
      }}/share/applications/keepassxc-autounlock.desktop"
    ];

    # KeePassXC is single-instance: if Plasma restored it from the last
    # session first, the auto-unlock launch would be swallowed.
    programs.plasma.configFile.ksmserverrc.General.excludeApps = "keepassxc";

    programs.keepassxc = {
      enable = true;
      autostart = false; # replaced by keepassxc-autounlock above
      settings = {
        General = {
          ConfigVersion = 2;
          AutoSaveAfterEveryChange = true;
          AutoTypeDelay = 25;
          MinimizeAfterUnlock = true;
          RememberLastKeyFiles = true;
        };

        Browser.Enabled = true;

        FdoSecrets = {
          Enabled = true; # Enable Secret Service Integration
          ShowNotification = false;
	  ConfirmAccessItem = false;
        };

        GUI = {
          ShowTrayIcon = true;
          TrayIconAppearance = "monochrome-light";
          MinimizeOnStartup = true;
          MinimizeToTray = true;
          MinimizeOnClose = true;
          ApplicationTheme = "dark";
        };

        Security = {
          # DuckDuckGo fallback for favicons
          IconDownloadFallback = true;
          LockDatabaseIdle = false;
          LockDatabaseScreenLock = false; # screen lock already guards the session
          LockDatabaseSleep = false;
          EnableQuickUnlock = true;
        };
      };
    };

    # kwallet: enabled only as Quick Unlock backend.
    # - Disabled for all other apps (no prompts, no popups)
    # - Secret Service API disabled so KeePassXC is the sole secrets provider
    xdg.configFile."kwalletrc".text = ''
      [Wallet]
      Enabled=true
      First Use=false
      Close When Idle=false
      Close on Screensaver=false
      Prompt on Open=false

      [org.freedesktop.secrets]
      apiEnabled=false
    '';



    # KDE: do not lock screen on resume from suspend (lid open)
    # Screen only locks on explicit lock or idle timeout

    xdg.configFile."kscreenlockerrc" = {
      text = lib.mkForce ''
        [Greeter][Wallpaper][org.kde.image][General]
        Image=file:///nix/store/1n95gvf26ipr5d6vavyjzam7879h8qps-plasma-workspace-wallpapers-6.5.6/share/wallpapers/Path/
        PreviewImage=file:///nix/store/1n95gvf26ipr5d6vavyjzam7879h8qps-plasma-workspace-wallpapers-6.5.6/share/wallpapers/Path/
        SlidePaths=/nix/store/0c1311gy20x5sshmh7dkppxhsx3czwkj-breeze-6.5.6/share/wallpapers/,/run/current-system/sw/share/wallpapers/
        [Daemon]
        Autolock=false
        LockOnResume=false
      '';
      force = true;
    };
  };
}

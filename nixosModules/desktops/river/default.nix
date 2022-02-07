{ config, lib, pkgs, self, ... }:

with lib;

let
  inherit (self.lib) mkEnableDefault;
  cfg = config.blasting.desktops.river;
  cfg' = config.blasting;
in {

  imports = [
    self.modules.desktops.common
  ];

  options.blasting.desktops.river = {
    enable = mkEnableDefault "Enable the River desktop (riverwm, gdm, waybar, ...)";
    kdeconnect = mkEnableDefault "Enable KDE Connect indicator and necessary firewall rules";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      river

      glib # gsettings
      gtk3.out # gtk-launch
      hicolor-icon-theme
      shared-mime-info
      xdg-user-dirs
      qt5.qtwayland # QT_QPA_PPLATFORM=wayland-egl

      oguri
      wlsunset
      wl-clipboard
      wl-clipboard-x11
      pamixer
      playerctl

      grim
      wev

      foot
      fuzzel

      gnome.nautilus
      gnome.gnome-system-monitor
    ]
    ++ (optional cfg.kdeconnect pkgs.kdeconnect);

    home-manager.users."${cfg'.user.username}" = let
      cfg'h = config.home-manager.users."${cfg'.user.username}";
    in {
      # TODO expose configuration options for hosts
      xdg.configFile = {
        "river/init".source =
          pkgs.writeShellScript "river_init"
            ''
              POLKIT_GNOME=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
              RIVERCTL=${pkgs.river}/bin/riverctl
              RIVERTILE=${pkgs.river}/bin/rivertile
              PAMIXER=${pkgs.pamixer}/bin/pamixer
              PLAYERCTL=${pkgs.playerctl}/bin/playerctl
              LIGHT=${pkgs.light}/bin/light
              FOOT=${pkgs.foot}/bin/foot
              FUZZEL=${pkgs.fuzzel}/bin/fuzzel

              ${lib.readFile ./init.sh}
            '';
        "oguri/config".text = ''
          [output *]
          image=${cfg'h.xdg.configHome}/oguri/wallpaper
          filter=nearest
          scaling-mode=fill
          anchor=center
        '';
        "oguri/wallpaper".source =
          ./wallpaper;
      };

      programs.waybar = import ./waybar.nix;
      services.kanshi = import ./kanshi.nix;
      services.wlsunset = {
        enable = true;
        latitude = "35.2";
        longitude = "-80.8";
      };
      systemd.user.services.oguri = {
        Unit = {
          Description = "A very nice animated wallpaper daemon for Wayland compositors.";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.oguri}/bin/oguri";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };

    programs.light.enable = true;
    programs.evince.enable = true;
    programs.file-roller.enable = true;
    programs.gnome-disks.enable = true;
    programs.seahorse.enable = true;

    networking.firewall = mkIf cfg.kdeconnect {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    programs.sway.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        terminal.vt = 2;
        default_session = let
          startriver = pkgs.writeShellScript "startriver"
            ''
              export XDG_SESSION_TYPE=wayland
              export XDG_SESSION_DESKTOP=river
              export XDG_CURRENT_DESKTOP=river

              export MOZ_DBUS_REMOTE=1
              export MOZ_ENABLE_WAYLAND=1
              export CLUTTER_BACKEND=wayland
              export QT_QPA_PLATFORM=wayland-egl
              export QT_WAYLAND_FORCE_DPI=physical
              export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
              export SDL_VIDEODRIVER=wayland
              export _JAVA_AWT_WM_NONREPARENTING=1

              river $@ | systemd-cat --identifier=river
            '';
        in {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${startriver}";
        };
      };
    };

    #FIXME
    services.xserver.libinput = let
      pointer = { natScroll ? false}:
        { accelProfile = "flat";
          naturalScrolling = natScroll;
          scrollMethod = "twofinger";
        };
    in {
      enable = false;
      mouse = pointer {};
      touchpad = pointer { natScroll = true; };
    };

    programs.dconf.enable = true;
    security.polkit.enable = true;
    services.power-profiles-daemon.enable = true;
    services.gvfs.enable = true;

    services.gnome = {
      gnome-keyring.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };
}

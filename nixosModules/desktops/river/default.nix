{ config, lib, pkgs, self, ... }:

with lib;

let
  inherit (self.lib) mkEnableDefault;
  cfg = config.blasting.desktops.river;
  cfg' = config.blasting;
in {

  imports = [ self.modules.desktops.common ];

  options.blasting.desktops.river = {
    enable =
      mkEnableDefault "Enable the River desktop (riverwm, gdm, waybar, ...)";
    kdeconnect = mkEnableDefault
      "Enable KDE Connect indicator and necessary firewall rules";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        river

        glib # gsettings
        gtk3.out # gtk-launch
        hicolor-icon-theme
        shared-mime-info
        xdg-user-dirs
        qt5.qtwayland # QT_QPA_PPLATFORM=wayland-egl
        libnotify # notify-send

        oguri
        wlsunset
        wl-clipboard
        wl-clipboard-x11
        pamixer
        playerctl

        slurp
        grim
        wev

        foot
        fuzzel
        gnome.eog

        gnome.nautilus
        gnome.gnome-system-monitor
      ] ++ (optional cfg.kdeconnect pkgs.kdeconnect);

    home-manager.users."${cfg'.user.username}" =
      let cfg'h = config.home-manager.users."${cfg'.user.username}";
      in {
        xdg.configFile = {
          "river/init".source = pkgs.writeShellScript "river_init" ''
            POLKIT_GNOME=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
            RIVERCTL=${pkgs.river}/bin/riverctl
            RIVERTILE=${pkgs.river}/bin/rivertile
            PAMIXER=${pkgs.pamixer}/bin/pamixer
            PLAYERCTL=${pkgs.playerctl}/bin/playerctl
            LIGHT=${pkgs.light}/bin/light
            FOOT=${pkgs.foot}/bin/foot
            FUZZEL=${pkgs.fuzzel}/bin/fuzzel

            # TODO: dynamically assign libinput configuration
            TRACKPADS=(1739:10629:Synaptics_s3203)

            ${lib.readFile ./init.sh}
          '';
          "oguri/config".text = ''
            [output *]
            image=${cfg'h.xdg.configHome}/oguri/wallpaper
            filter=nearest
            scaling-mode=fill
            anchor=center
          '';
          "oguri/wallpaper".source = ./wallpaper;
          "xdg-desktop-portal-wlr/config".text = ''
            [screencast]
            output_name=eDP-1
            max_fps=60
            chooser_type=simple
            chooser_cmd=slurp -f %o -or
          '';
        };

        systemd.user.targets.river-session = {
          Unit = {
            Description = "graphical river (wayland) session";
            Documentation = [ "man:systemd.special(7)" ];
            BindsTo = [ "graphical-session.target" ];
            Wants = [ "graphical-session-pre.target" ];
            After = [ "graphical-session-pre.target" ];
          };
        };

        # TODO: add service definitions to home-manager modules
        systemd.user.services = import ./user-services.nix { inherit pkgs cfg'h; };

        programs.waybar = import ./waybar.nix { inherit pkgs cfg'h; };
        programs.mako = import ./mako.nix { inherit pkgs cfg'h; };
        programs.foot = import ./foot.nix { inherit pkgs cfg'h; };
        services.kanshi = import ./kanshi.nix { inherit pkgs cfg'h; };
        services.swayidle = import ./swayidle.nix { inherit pkgs cfg'h; };
        services.wlsunset = {
          enable = true;
          latitude = "35.2";
          longitude = "-80.8";
        };
      };

    programs.light.enable = true;
    programs.evince.enable = true;
    programs.file-roller.enable = true;
    programs.gnome-disks.enable = true;
    programs.seahorse.enable = true;

    networking.firewall = mkIf cfg.kdeconnect {
      allowedTCPPortRanges = [{
        from = 1714;
        to = 1764;
      }];
      allowedUDPPortRanges = [{
        from = 1714;
        to = 1764;
      }];
    };

    programs.sway.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        terminal.vt = 2;
        default_session = let
          startriver = pkgs.writeShellScript "startriver" ''
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

    programs.dconf.enable = true;
    security.polkit.enable = true;
    services.power-profiles-daemon.enable = true;
    services.gvfs.enable = true;

    services.gnome = { gnome-keyring.enable = true; };

    xdg.portal.enable = true;
    xdg.portal.extraPortals =
      [
        (pkgs.xdg-desktop-portal-gtk.override { buildPortalsInGnome = false; })
        pkgs.xdg-desktop-portal-wlr ];
  };
}

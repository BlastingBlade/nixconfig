{ config, lib, pkgs, self, ... }:

with lib;

let
  inherit (self.lib) mkEnableDefault;
  cfg = config.blasting.desktops;
  cfg' = config.blasting;
in {

  imports = [
    ./browser.nix
    ./emacs.nix
    ./email.nix
    ./interception-tools.nix
    ./utilities.nix
  ];

  options.blasting.desktops = {
    networkmanager = {
      enable = mkEnableDefault "Configure with NetworkManager";
      #wireless = mkEnable "Enable wireless";
      #modemmanager = mkEnable;
      powersaving = mkEnableDefault "Enable powersaving";
    };

    adb.enable = mkEnableOption "Enable the Android Debugging Bridge";
    qmk.enable = mkEnableDefault "Enable udev rules for QMK devices";
    v4l2loopback.enable =
      mkEnableOption "Enable the v4l2loopback kernel module";
  };

  config = {
    environment.systemPackages = with pkgs; [ pkgs.pulsemixer pkgs.libsecret ];

    users.users."${cfg'.user.username}".extraGroups = [ "video" "dialout" ]
      ++ optional cfg.networkmanager.enable "networkmanager"
      ++ optional cfg.adb.enable "adbusers";

    fonts.fonts = with pkgs; [
      fira
      fira-code
      fira-code-symbols
      cantarell-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      liberation_ttf
      libertine
      font-awesome-ttf

      emacs-all-the-icons-fonts
    ];

    services.flatpak.enable = true;

    programs.adb.enable = cfg.adb.enable;

    services.udev.packages = optional cfg.qmk.enable pkgs.qmk-udev-rules;

    networking.networkmanager = mkIf cfg.networkmanager.enable {
      enable = true;
      dhcp = "internal";
      wifi = { powersave = cfg.networkmanager.powersaving; };
    };

    home-manager.users."${cfg'.user.username}" = {
      xdg.userDirs = {
        enable = true;
        desktop = "$HOME/.desktop";
        documents = "$HOME/Documents";
        download = "$HOME/Downloads";
        music = "$HOME/Music";
        pictures = "$HOME/Pictures";
        publicShare = "$HOME/Documents/Share";
        templates = "$HOME/Documents/Templates";
        videos = "$HOME/Videos";
      };

      gtk = {
        enable = true;
        font = {
          name = "Cantarell";
          package = pkgs.cantarell-fonts;
          size = 10;
        };
        theme = {
          package = pkgs.gnome.gnome-themes-extra;
          name = "Adwaita-dark";
        };
        gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };

    # pipewire
    sound.enable = false;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;

      media-session.enable = true;
    };

    console = {
      earlySetup = true;
      keyMap = "us";
      font = "Lat2-Terminus16";
      colors = (let
        schemes = {
          nord = [
            "292d3e"
            "f07178"
            "c3e88d"
            "ffcb6b"
            "82aaff"
            "c792ea"
            "89ddff"
            "d0d0d0"
            "434758"
            "ff8b92"
            "ddffa7"
            "ffe585"
            "9cc4ff"
            "e1acff"
            "a3f7ff"
            "ffffff"
          ];
        };
      in schemes.nord);
    };

    boot.extraModulePackages =
      optional cfg.v4l2loopback.enable config.boot.kernelPackages.v4l2loopback;
    boot.kernelModules = [ "uinput" ]
      ++ optional cfg.v4l2loopback.enable "v4l2loopback";
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blasting.desktop;
  mkEnableDefault = desc: mkEnableOption desc // { default = true; };
in {

  options.blasting.desktop = {
    console = {
      colors = {
        enable = mkEnableDefault "Set colors for the console";
        scheme = mkOption {
          type = types.enum [ "nord" ]; # "palenight"
          description = "Colorscheme (theme)";
          default = "nord";
        };
      };
    };

    fonts = {
      enable = mkEnableDefault "Install fonts";
      extra = mkOption {
        type = with types; listOf package;
        description = "Install these fonts too";
        default = with pkgs; [];
        example = literalExample "with pkgs; [ sourcecodepro ]";
      };
    };

    input.keyboard.capstoesc.enable = mkEnableDefault "Use Interception Tools to remap capslock to ctrl/esc";

    devices = {
      adb = {
        enable = mkEnableOption "Enable the Android Debugging Bridge";
        users = mkOption {
          type = with types; listOf str;
          description = "Users granted control of ADB devices";
          default = singleton config.blasting.common.user.username;
          example = literalExample "[ alice bob ]";
        };
      };
      dialout = {
        users = mkOption {
          type = with types; listOf str;
          description = "Users granted control of dialout devices (arduino)";
          default = singleton config.blasting.common.user.username;
          example = literalExample "[ alice bob ]";
        };
      };
      video = {
        users = mkOption {
          type = with types; listOf str;
          description = "Users granted control of video devices";
          default = singleton config.blasting.common.user.username;
          example = literalExample "[ alice bob ]";
        };
      };
    };

    networkmanager = {
      enable = mkEnableDefault "Configure with NetworkManager";
      #wireless = mkEnable "Enable wireless";
      #modemmanager = mkEnable;
      powersaving = mkEnableDefault "Enable powersaving";
      users = mkOption {
        type = with types; listOf str;
        description = "Users granted control of NetworkManager";
        default = singleton config.blasting.common.user.username;
        example = literalExample "[ alice bob ]";
      };
    };

    pipewire.enable = mkEnableDefault "Configure pipewire";

    libsecret.enable = mkEnableDefault "Enable the libsecret secret manager";

    v4l2loopback = {
      enable = mkEnableOption "Enable a v4l2 loopback device";
      exclusiveCaps = mkEnableDefault "Enable 'exclusive_caps' option (chrome compat)";
      # TODO: devices = listOf uint where 'label = number' for video_nr=number,number and card_label=label,label
    };

    gnome = {
      enable = mkEnableDefault "Enable the GNOME desktop (gnome, gdm, apps, ...)";
      gsconnect = mkEnableDefault "Enable thee GSConnect extension";
    };
  };

  config = {
    environment.systemPackages =
      optional cfg.pipewire.enable pkgs.pulsemixer
      ++ optional cfg.libsecret.enable pkgs.gnome.libsecret
      ++ optionals cfg.gnome.enable (with pkgs; [
        gnome.baobab
        gnome.eog
        gnome.gedit
        gnome.gnome-calculator
        gnome.gnome-screenshot
        gnome.gnome-system-monitor
        gnome.nautilus
      ] ++ (with pkgs.gnomeExtensions; [
        appindicator
        adwaita-theme-switcher
        espresso
      ] ++ optional cfg.gnome.gsconnect pkgs.gnomeExtensions.gsconnect))
    ;

    # TODO: map over users attr of each cfg, adding matching extaGroups entry
    users.users.blasting.extraGroups = [
      "networkmanager"
      "adbusers"
      "video"
      "dialout"
    ];

    fonts.fonts = optionals cfg.fonts.enable (with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      liberation_ttf
      libertine
    ]
    ++ cfg.fonts.extra);

    programs.adb.enable = cfg.devices.adb.enable;

    networking.networkmanager = mkIf cfg.networkmanager.enable {
      enable = true;
      dhcp = "internal";
      wifi = {
        powersave = cfg.networkmanager.powersaving;
      };
    };

    sound.enable = mkIf cfg.pipewire.enable false;
    hardware.pulseaudio.enable = mkIf cfg.pipewire.enable false;
    security.rtkit.enable = mkIf cfg.pipewire.enable true;
    services.pipewire = mkIf cfg.pipewire.enable {
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
      colors = mkIf cfg.console.colors.enable (let
        knownSchemes = {
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
      in getAttrFromPath [cfg.console.colors.scheme] knownSchemes);
    };

    services.interception-tools = mkIf cfg.input.keyboard.capstoesc.enable {
      enable = true;
      #caps2esc config is defaut :D
      #plugins = [];
      #udevmonConfig = '''';
    };

    services.flatpak.enable = true;

    networking.firewall = mkIf (cfg.gnome.enable && cfg.gnome.gsconnect) {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    boot.extraModulePackages = optional
      cfg.v4l2loopback.enable config.boot.kernelPackages.v4l2loopback;
    boot.kernelModules = [ "uinput" ]
      ++ optional cfg.v4l2loopback.enable "v4l2loopback";
    boot.extraModprobeConfig = optionalString
      cfg.v4l2loopback.enable ''
      options v4l2loopback ${optionalString cfg.v4l2loopback.exclusiveCaps "exclusive_caps=1"} card_label=Video_Loopback
    '';

    services.xserver = mkIf cfg.gnome.enable {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    services.gnome  = mkIf cfg.gnome.enable {
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = false;

      gnome-online-accounts.enable = false;
      chrome-gnome-shell.enable = false;
      gnome-initial-setup.enable = false;
      gnome-remote-desktop.enable = false;
      gnome-user-share.enable = false;
      rygel.enable = false;
      sushi.enable = true;
    };
    services.packagekit.enable = false;
    services.telepathy.enable = false;

    services.udev.packages = optional cfg.gnome.enable (with pkgs; [
      gnome3.gnome-settings-daemon
    ]);

    environment.gnome.excludePackages = optional cfg.gnome.enable (with pkgs; [
      gnome-tour
      orca
    ]);

    programs.evince.enable = cfg.gnome.enable;
    programs.file-roller.enable = cfg.gnome.enable;
    programs.gnome-disks.enable = cfg.gnome.enable;
    programs.gnome-terminal.enable = cfg.gnome.enable;
    programs.seahorse.enable = cfg.gnome.enable;

    qt5.platformTheme = mkIf cfg.gnome.enable "gnome";
  };
}

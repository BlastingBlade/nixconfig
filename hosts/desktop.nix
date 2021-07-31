{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    pulsemixer
    libsecret
    gnome.libsecret
    brightnessctl

    ((emacsPackagesNgGen emacsPgtkGcc).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
  ];

  users.users.blasting.extraGroups = [
      "networkmanager"
      "adbusers"
      "video"
    ];

  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    colors = [
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
    keyMap = "us";
  };

  services.interception-tools = {
    enable = true;
    #caps2esc config is defaut :D
    #plugins = [];
    #udevmonConfig = '''';
  };

  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    media-session.enable = true;
  };

  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dhcp = "internal";
      wifi = {
        backend = "iwd";
        #macAddress = "random";
        powersave = true;
      };
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label=Video_Loopback
  '';
}

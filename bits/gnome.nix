{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;

    desktopManager.gnome.enable = true;
  };
  services = {
    gnome = {
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
    packagekit.enable = false;
    telepathy.enable = false;
  };
  hardware.pulseaudio.enable = false;

  services.udev.packages = with pkgs; [
    gnome3.gnome-settings-daemon
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    orca
  ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator

    gnome.baobab
    gnome.eog
    gnome.gedit
    gnome.gnome-calculator
    gnome.gnome-screenshot
    gnome.gnome-system-monitor
    gnome.nautilus

    gnome.dconf-editor
  ];

  programs = {
    evince.enable = true;
    file-roller.enable = true;
    gnome-disks.enable = true;
    gnome-terminal.enable = true;
    seahorse.enable = true;
  };

  qt5.platformTheme = "gnome";
}

{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    nodejs
    tmux
  ];

  networking = {
    hostName = "planeptune";
    usePredictableInterfaceNames = false;

    firewall = {
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
      allowedTCPPorts = [ 22 8000 ];
    };
  };

  services.openssh.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}

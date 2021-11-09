{ config, pkgs, lib, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

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
      allowedTCPPorts = [ 8000 ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}

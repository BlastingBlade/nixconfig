{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  services.haveged.enable = true;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    hostName = "planeptune";

    interfaces = {
      eth0.useDHCP = true;
      wlan0 = {
        useDHCP = false;
        ipv4.addresses = lib.mkOverride 0 [
          { address = "192.168.1.1"; prefixLength = 24; }
        ];
      };
    };

    firewall = {
      enable = true;
      allowPing = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
      interfaces.wlan0.allowedTCPPorts = [ 22 8000 ];
      interfaces.wlan0.allowedUDPPorts = [ 53 67 ];
      extraCommands = ''
        iptables -w -t nat -I POSTROUTING -s 192.168.1.0/24 ! -o wlan0 -j MASQUERADE
        iptables -w -I FORWARD -i wlan0 -s 192.168.1.0/24 -j ACCEPT
        iptables -t mangle -A PREROUTING -i wlan0 -j TTL --ttl-set 64
        iptables -w -I FORWARD -i eth0 -d 192.168.1.0/24 -j ACCEPT
        iptables -t mangle -A PREROUTING -i eth0 -j TTL --ttl-set 64
      '';
    };
  };

  services.hostapd = {
    enable = true;
    interface = "wlan0";
    hwMode = "g";
    ssid = "planeptune";
    wpa = true; # wpa2 is used
    wpaPassphrase = "NUcVf2pO"; # plaintext passwd, sue me!
    countryCode = "US";
    group = "wheel";
  };

  services.dnsmasq = {
    enable = true;
    servers = [
      # OpenDNS
      "208.67.222.222"
      "208.67.220.220"
      "2620:119:35::35"
      "2620:119:53::53"
    ];
    extraConfig = ''
      interface=wlan0
      bind-interfaces
      dhcp-range=192.168.1.10,192.168.1.254,24h
    '';
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

{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  networking.hostName = "histoire";

  environment.persistence."/nix/persist" = {
    directories = [
      "/srv"       # service data
      "/var/lib"   # system service persistent data
      "/var/log"   # the place that journald dumps it logs to
      "/home"      # user dirs
    ];
  };
  environment.etc."machine-id".source
    = "/nix/persist/etc/machine-id";

  services.openssh.hostKeys = [
    { bits = 4096;
      path = "/nix/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    { path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];

  networking = {
    useDHCP = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0 = {
      useDHCP = true;
    };
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  users = {
    mutableUsers = false;
    users = {
      root.initialHashedPassword = "$6$jTnBoykh2C$c3xA1b0jHixv6WeFIQCmQ0Vc1l.N.l5Uc0t7/d.WPbkd8vERnWjZv8ZgGPNshPr3cME.RXGiOe5oi5hm2ym/q1";
      blasting.initialHashedPassword = "$6$jTnBoykh2C$c3xA1b0jHixv6WeFIQCmQ0Vc1l.N.l5Uc0t7/d.WPbkd8vERnWjZv8ZgGPNshPr3cME.RXGiOe5oi5hm2ym/q1";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "hfiantaca.com" = {
        addSSL = true;
        enableACME = true;
        root = "/srv/www/hfiantaca.com";
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    email = "hfiantaca@gmail.com";
  };

  services.avahi.enable = lib.mkForce false;

  #FIXME grub cannot find grub.cfg on boot
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        forceInstall = true;
        copyKernels = true;
        fsIdentifier = "label";
        extraConfig = ''
          serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
          terminal_input serial;
          terminal_output serial
        '';
      };
      timeout = 10;
    };
    kernelParams = [ "console=ttyS0,19200n8" ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    initrd.availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"
      "ahci"
      "sd_mod"
    ];
    initrd = {
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
      postDeviceCommands = ''
        hwclock -s
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=512M" "mode=755" ];
    };

    "/nix" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

}


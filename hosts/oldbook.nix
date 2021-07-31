{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  networking.hostName = "oldbook";

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = lib.mkDefault(pkgs.linuxPackages_latest);
    kernelModules = lib.mkDefault([ "kvm-intel" ]);

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "sd_mod"
        "sr_mod"
        "rtsx_usb_sdmmc"
      ];

      luks.devices."NixOS".device = "/dev/disk/by-uuid/72ffb197-a853-436e-a188-580be0fd53e0";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a6285339-338f-4694-8299-af31561b25bd";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/a6285339-338f-4694-8299-af31561b25bd";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime"];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/a6285339-338f-4694-8299-af31561b25bd";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime"];
    };

    "/persist" = {
      device = "/dev/disk/by-uuid/a6285339-338f-4694-8299-af31561b25bd";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime"];
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/a6285339-338f-4694-8299-af31561b25bd";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime"];
      neededForBoot = true;
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/EAFD-5094";
      fsType = "vfat";
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/c674f83a-efcb-4177-9002-d8f8a42c7296"; }
  ];
}

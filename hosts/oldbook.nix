{ config, lib, pkgs, nixos-hardware, impermanence, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-gpu-nvidia-disable
    nixos-hardware.nixosModules.dell-latitude-3480
    impermanence.nixosModules.impermanence
  ];

  networking.hostName = "oldbook";

  hardware.enableRedistributableFirmware = true;

  #hardware.bluetooth.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  environment.sessionVariables = { "VDPAU_DRIVER" = "va_gl"; };

  blasting.desktops = {
    adb.enable = true;
    v4l2loopback.enable = true;
    interception-tools.caps2esc = {
      events = null;
      devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" "rtsx_usb_sdmmc" ];

      luks.devices = let
        discarding = dev: {
          device = dev;
          allowDiscards = true;
        };
      in {
        "NixOS" =
          discarding "/dev/disk/by-uuid/2208b83c-fea2-4d91-83be-426e9b59a725";
        "NixSwap" =
          discarding "/dev/disk/by-uuid/4bab5979-8e36-40bf-90d2-5580ac77669b";
        "NixHome" =
          discarding "/dev/disk/by-uuid/2edb188d-8428-4fab-80c6-190808eb9450";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/e6ae7a64-f2f1-4c48-b01e-f1eee7d15d01";
      fsType = "ext4";
      options = [ "defaults" "discard" "noatime" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/5a74542d-0ed6-4a61-9337-eaff49df2a68";
      fsType = "ext4";
      options = [ "defaults" "discard" "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/BA39-F64A";
      fsType = "vfat";
      options = [ "defaults" "discard" ];
    };
  };
  swapDevices =
    [{ device = "/dev/disk/by-uuid/f8fc6d65-eab1-4e88-a30d-868bd2ea77a4"; }];

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager"
      "/srv"
      "/var/lib"
      "/var/log"
    ];
  };
}

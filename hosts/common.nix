{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    vim
    git
    nix-index
  ];

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  users.users.blasting = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  virtualisation.podman.enable = true;
}

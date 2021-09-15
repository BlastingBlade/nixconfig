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
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmKlAu/Fgvt5TYZgBV3aZdoTQ+SfI/x+0zUEsyK9ET1 hfiantaca@gmail.com"
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    openFirewall = true;
  };

  virtualisation.podman.enable = true;
}

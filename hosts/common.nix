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
    initialHashedPassword = "$6$jTnBoykh2C$c3xA1b0jHixv6WeFIQCmQ0Vc1l.N.l5Uc0t7/d.WPbkd8vERnWjZv8ZgGPNshPr3cME.RXGiOe5oi5hm2ym/q1";
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
    hostKeys = [
      {
        path = "/nix/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/nix/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
    passwordAuthentication = false;
    openFirewall = true;
  };

  virtualisation.podman.enable = true;
}

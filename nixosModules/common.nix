{ config, lib, pkgs, self, ... }:

with lib;

let
  inherit (self.lib) mkEnableDefault;
  cfg = config.blasting;
in
{
  options.blasting = {
    user = {
      username = mkOption {
        type = types.str;
        description = "Username of the main user";
        default = "blasting";
      };
      realname = mkOption {
        type = types.str;
        description = "Real name of the main user";
        default = "Henry Fiantaca";
      };
      email = mkOption {
        type = types.str;
        description = "Email of the user";
        default = "hfiantaca@gmail.com";
      };
      sshAuthorizedKeys = mkOption {
        type = with types; listOf str;
        description = "Authorized SSH keys";
        example = literalExample "[ \"ssh-rsa somefactor user@host\" ]";
      };
      passwordHash = mkOption {
        type = types.str;
        description = "Hashed password, recived from 'mkpasswd -m SHA-512 -s'";
      };
    };

    services = {
      mdns.enable = mkEnableDefault "Enable mDNS and zeroconf via avahi";
      ssh.enable = mkEnableDefault "Enable SSH";
      podman.enable = mkEnableOption "Enable podman container hypervisor";
    };
  };

  config = {
    users.users."${cfg.user.username}" = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      initialHashedPassword = cfg.user.passwordHash;
      openssh.authorizedKeys.keys = cfg.user.sshAuthorizedKeys;
    };

    home-manager.users."${cfg.user.username}" = {
      programs.home-manager.enable = true;

      programs.bash = {
        enable = true;
        historyControl = [ "erasedups" "ignorespace" ];
        shellAliases = {
          ll = "ls -l";
        };
      };

      programs.git = {
        enable = true;
        userName  = cfg.user.realname;
        userEmail = cfg.user.email;
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

      programs.gpg.enable = true;
      services.gpg-agent.enable = true;

      programs.man = {
        enable = true;
        generateCaches = true;
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      git
      (ripgrep.override { withPCRE2 = true; })
      fd
      file
      python3
    ];

    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    services.avahi = mkIf cfg.services.mdns.enable {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    services.openssh = mkIf cfg.services.ssh.enable {
      enable = true;
      hostKeys = mkIf (hasAttrByPath [ "persistence" "/nix/persist" ] config.environment) [
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

    virtualisation.podman.enable = cfg.services.podman.enable;
  };
}

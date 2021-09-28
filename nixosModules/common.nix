{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.blasting.common;
  mkEnableDefault = desc: mkEnableOption desc // { default = true; };
in
{
  options.blasting.common = {
    user = {
      username = mkOption {
        type = types.str;
        description = "Username of the main user";
      };
      realname = mkOption {
        type = types.str;
        description = "Real name of the main user";
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

    mdns.enable = mkEnableDefault "Enable mDNS and zeroconf via avahi";

    podman.enable = mkEnableDefault "Enable podman container hypervisor";

    ssh.enable = mkEnableDefault "Enable SSH";

    vim.enable = mkEnableDefault "Install vim as EDITOR";
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

    environment.systemPackages = optional cfg.vim.enable pkgs.vim;
    environment.variables = mkIf cfg.vim.enable {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    services.avahi = mkIf cfg.mdns.enable {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    services.openssh = mkIf cfg.ssh.enable {
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

    virtualisation.podman.enable = cfg.podman.enable;
  };
}

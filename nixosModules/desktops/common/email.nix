{ config, lib, pkgs, self, ... }:

with lib;

let
  cfg' = config.blasting;

  makeGmailAccount = { address, signature ? "", primary ? false }: {
    inherit primary;
    address = address;
    realName = "Henry Fiantaca";
    signature = {
      showSignature = "append";
      text = signature;
    };
    userName = address;
    passwordCommand = "secret-tool lookup app-pwd ${address}";
    flavor = "gmail.com";
    mbsync = {
      enable = true;
      create = "maildir";
    };
    msmtp.enable = true;
    mu.enable = true;
  };
in {
  home-manager.users."${cfg'.user.username}" = {
    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.mu.enable = true;
    accounts.email = {
      accounts = {
        "gmail" = makeGmailAccount {
          address = "hfiantaca@gmail.com";
          signature = ''

            -- Henry Fiantaca
          '';
          primary = true;
        };
        "uncc" = makeGmailAccount {
          address = "hfiantac@uncc.edu";
          signature = ''

            -- Henry Fiantaca
               801075065
               CCI Undergraduate
          '';
        };
      };
      maildirBasePath = "/home/blasting/.local/share/maildir";
    };
  };
}

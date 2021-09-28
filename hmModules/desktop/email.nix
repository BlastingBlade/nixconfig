{ lib, pkgs, ... }:

{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.mu.enable = true;
  accounts.email = {
    accounts =
      let
        makeGmailAccount = { address, signature ? "" }:
          {
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
      in
        {
          "gmail" = (makeGmailAccount {
            address = "hfiantaca@gmail.com";
            signature = ''

            -- Henry Fiantaca
            '';
          } // { primary = true; });
          "uncc" = makeGmailAccount {
            address = "hfiantac@uncc.edu";
            signature = ''

            -- Henry Fiantaca
              801075065
              Undergraduate of CCI
            '';
          };
        };
    maildirBasePath = "/home/blasting/.local/share/maildir";
  };
}

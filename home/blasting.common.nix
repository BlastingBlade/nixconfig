{ lib, pkgs, ... }:

{
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
    userName  = "Henry Fiantaca";
    userEmail = "hfiantaca@gmail.com";
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
}

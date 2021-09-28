{ pkgs, ... }:

{ config, lib, ... }:

with lib;

let
  cfg = config.blasting.common;
  mkEnableDefault = desc: mkEnableOption desc // { default = true; };
in
{
  options.blasting.common = {
    bash = {
      enable = mkEnableDefault "Apply bash configuration";
    };
    git = {
      enable = mkEnableDefault "Apply git configuration";
      userName  = mkOption {
        type = types.str;
        description = "user.name in git";
        default = "Henry Fiantaca";
      };
      userEmail = mkOption {
        type = types.str;
        description = "user.email in git";
        default = "hfiantaca@gmail.com";
      };
    };
  };

  config = {
    programs.home-manager.enable = true;

    programs.bash = mkIf cfg.bash.enable {
      enable = true;
      historyControl = [ "erasedups" "ignorespace" ];
      shellAliases = {
        ll = "ls -l";
      };
    };

    programs.git = mkIf cfg.git.enable {
      enable = true;
      userName  = cfg.git.userName;
      userEmail = cfg.git.userEmail;
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
}

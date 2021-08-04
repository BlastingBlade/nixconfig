{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-runtime"
    "steam-original"
    "discord"
  ];

  /*
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      nativeOnly = true;
    };
  };
  */

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    steam.run

    discord
    betterdiscordctl
  ];
}

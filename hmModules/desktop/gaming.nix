pkgs:
{ lib, ... }:

{
  home.packages = with pkgs; [
    lutris
    steam
    steam.run
    discord
  ];
}

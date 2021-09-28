{ lib, pkgs, ... }:

{
  gtk = {
    enable = true;
    font ={
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
      size = 10;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}

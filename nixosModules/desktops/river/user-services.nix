{ pkgs, ... }:

{
  swayidle = {
    Service = { Environment = [ "PATH=/run/current-system/sw/bin" ]; };
    Install = { WantedBy = pkgs.lib.mkForce [ "graphical-session.target" ]; };
  };

  mako = {
    Unit = {
      Description =
        " A lightweight Wayland notification daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = { ExecStart = "${pkgs.mako}/bin/mako"; };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  oguri = {
    Unit = {
      Description =
        "A very nice animated wallpaper daemon for Wayland compositors.";
      PartOf = [ "graphical-session.target" ];
    };
    Service = { ExecStart = "${pkgs.oguri}/bin/oguri"; };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}

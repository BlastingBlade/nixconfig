{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    buildah

    freecad
    blender
    prusa-slicer
  ];

  programs.mpv = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
      obs-gstreamer
      obs-v4l2sink
      obs-wlrobs
    ];
  };
}

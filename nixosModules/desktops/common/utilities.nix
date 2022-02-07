{ config, lib, pkgs, self, ... }:

with lib;

let
  cfg' = config.blasting;
  passExt = pkgs.pass.withExtensions (exts: [
    exts.pass-audit
    exts.pass-otp
    exts.pass-update
  ]);
  obsExt = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-websocket
      wlrobs
    ];
  };
in {
  environment.systemPackages = with pkgs; [
    passExt

    scrcpy
    imagemagick
    mpv

    texlive.combined.scheme-full
    python39Packages.pygments
    graphviz

    obsExt

    freecad
    blender
    prusa-slicer
  ];


  environment.variables = {
    PASSWORD_STORE_DIR = "$HOME/.local/share/pass";
    PASSWORD_STORE_CLIP_TIME = "60";
  };
}

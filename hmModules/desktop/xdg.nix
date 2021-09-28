{ lib, pkgs, ... }:

{
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME/.desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Documents/Share";
    templates = "$HOME/Documents/Templates";
    videos = "$HOME/Videos";
  };
}

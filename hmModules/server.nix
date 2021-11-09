{ config, lib, pkgs, self, ... }:

{
  imports = [ self.hmModules.common ];

  home.packages = with pkgs; [
    tmux
    nodejs
  ];

  # TODO: enable services for server use
}

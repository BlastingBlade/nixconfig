{ pkgs, inputs, ... }:

{ config, lib, ... }:

{
  imports = [ inputs.self.hmModules.common ];

  home.packages = with pkgs; [
    tmux
    nodejs
  ];

  # TODO: enable services for server use
}

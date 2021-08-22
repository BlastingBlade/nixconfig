{ lib, pkgs, ... }:

{
  imports = [ ./blasting.common.nix ];

  home.packages = with pkgs; [
    nodejs
  ];

  # TODO: enable services for server use
}

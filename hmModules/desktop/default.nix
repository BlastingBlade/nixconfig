{ config, lib, pkgs, self, nix-doom-emacs, ... }:

{
  imports = [
    self.hmModules.common
    ./browser.nix
    ./doom-emacs.nix
    ./email.nix
    ./pass.nix
    ./texlive.nix
    ./theming.nix
    ./xdg.nix
    ./misc.nix
  ];
}

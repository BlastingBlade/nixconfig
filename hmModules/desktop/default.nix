{ pkgs, inputs, ... }:

{ config, lib, ... }:

{
  imports = [
    inputs.self.hmModules.common
    inputs.nix-doom-emacs.hmModule
    ./browser.nix
    (import ./doom-emacs.nix pkgs)
    ./email.nix
    ./pass.nix
    ./texlive.nix
    ./theming.nix
    ./xdg.nix
    ./misc.nix
  ];
}

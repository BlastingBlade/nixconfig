{ config, lib, pkgs, self, ... }:

with lib;

let
  cfg = config.blasting.common;
  mkEnableDefault = desc: mkEnableOption desc // { default = true; };
in
{
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  environment.systemPackages = with pkgs; [ git gnumake ];

  nix.generateRegistryFromInputs = true;
  nix.generateNixPathFromInputs = true;
  nix.linkInputs = true;
}

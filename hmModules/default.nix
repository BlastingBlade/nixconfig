{ pkgs, inputs, pkgsNonfree, ... }@header:

{
  common  = import ./common.nix header;
  desktop = import ./desktop header;
  server  = import ./server.nix header;
}

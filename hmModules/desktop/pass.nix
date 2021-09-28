{ lib, pkgs, ... }:

{
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      exts.pass-audit
      exts.pass-otp
      exts.pass-update
    ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.local/share/pass";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
  };
}

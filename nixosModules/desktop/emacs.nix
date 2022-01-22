{ config, lib, pkgs, self, ... }:

with lib;

let
  cfg' = config.blasting;
in {
  home-manager.users."${cfg'.user.username}" = {
    home.sessionPath = [ "~/.config/emacs/bin" ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacsPgtkGcc;
      extraPackages = (epkgs: [
        pkgs.emacs-all-the-icons-fonts
        pkgs.binutils
        pkgs.mu
        epkgs.vterm
      ]);
    };

    services.emacs = {
      enable = true;
      client = {
        enable = true;
        arguments = [ "-c" ];
      };
    };

    # TODO: Move into project devShells
    home.packages = with pkgs; [
      # :checkers spell
      (pkgs.aspellWithDicts (ds: with ds; [
        en en-computers en-science
      ]))
      # :checkers grammer
      languagetool
      # :editor format
      asmfmt
      clang-tools # clang-fomat
      cmake-format
      htmlTidy
      nixfmt
      rustfmt
      black # python
      shfmt
      # :tools editorconfig
      editorconfig-core-c
      # :tools lookup
      sqlite
      wordnet
      # :lang org +hugo
      hugo
      # :lang cc
      ccls
      bear
      clang
      # :lang javascript
      nodePackages.javascript-typescript-langserver
      # :lang rust
      rust-analyzer
      cargo
      rustc
    ];
  };
}

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Emacs 28 with Pgtk and native-comp
    ((emacsPackagesNgGen emacsPgtkGcc).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
    binutils

    # core
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    # optional
    fd
    imagemagick
    pinentry_emacs
    zstd

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [
      en en-computers en-science
    ]))
    # :checkers grammar
    languagetool
    # :tools editorconfig
    editorconfig-core-c
    # :lang cc
    ccls
    # :lang javascript
    nodePackages.javascript-typescript-langserver
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang rust
    rustfmt
    unstable.rust-analyzer

    emacs-all-the-icons-fonts
  ];
}

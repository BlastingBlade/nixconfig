{ config, pkgs, lib, modulesPath, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Emacs 28 with native-comp
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
    # :tools direnv
    direnv
    # :tools editorconfig
    editorconfig-core-c
    # :tools lookup & :lang org +roam
    sqlite
    # :lang cc
    ccls
    glslang
    # :lang markdown
    discount
    grip
    # :lang nix
    nixfmt
    # :lang javascript
    nodePackages.javascript-typescript-langserver
    # :lang latex & :lang org
    (texlive.combine { inherit (texlive)
        scheme-medium
        wrapfig
        minted
        fvextra
        upquote
        catchfile
        xstring
        framed
        titling
    ;})
    python39Packages.pygments
    graphviz
    # :lang rust
    rustfmt
    rust-analyzer
    # :lang sh
    shellcheck
  ];

  fonts.fonts = with pkgs; [
    fira
    fira-code
    fira-code-symbols
    font-awesome_5
    emacs-all-the-icons-fonts
  ];
}

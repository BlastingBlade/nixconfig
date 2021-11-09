{ lib, pkgs, ... }:

{
  home.sessionPath = [ "~/.config/emacs/bin" ];

  programs.emacs = {
    enable = true;
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

  fonts.fontconfig.enable = lib.mkForce true;

  home.packages = with pkgs; [
    # doom depends
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    fd
    imagemagick

    fira
    fira-code
    fira-code-symbols

    # :checkers spell
    (pkgs.aspellWithDicts (ds: with ds; [
      en en-computers en-science
    ]))
    # :checkers grammer
    languagetool
    # :ui treemacs
    python3
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
    # :lang latex
    python39Packages.pygments
    graphviz
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
}

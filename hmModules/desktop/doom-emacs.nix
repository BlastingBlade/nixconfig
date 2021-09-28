pkgs:
{ lib, ... }:

{
  programs.doom-emacs = {
    enable = true;
    emacsPackage = pkgs.emacsPgtkGcc;
    # emacsPackagesOverlay
    doomPrivateDir = ./doom.d;
    extraPackages = [ pkgs.mu ];
    extraConfig = ''
      (setq sendmail-program "${pkgs.msmtp}/bin/msmtp"
            mu4e-mu-binary "${pkgs.mu}/bin/mu")
    '';
  };
  services.emacs = {
    enable = true;
    client = {
      enable = true;
      arguments = [ "-c" ];
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # doom depends
    fira
    fira-code
    fira-code-symbols
    emacs-all-the-icons-fonts
    # :checkers spell
    (pkgs.aspellWithDicts (ds: with ds; [
      en en-computers en-science
    ]))
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
    rustfmt
    rust-analyzer
    cargo
    rustc

    fd
    (ripgrep.override { withPCRE2 = true; })
  ];
}

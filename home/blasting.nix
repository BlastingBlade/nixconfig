{ lib, pkgs, nix-doom-emacs, ... }:

{
  imports = [
    ./blasting.common.nix
    nix-doom-emacs.hmModule
  ];

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
    direnv
    nixfmt

    buildah

    lutris

    freecad
    blender
    prusa-slicer

  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

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

  fonts.fontconfig.enable = true;
  programs.texlive = {
    enable = true;
    packageSet = pkgs.texlive;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        scheme-medium
        collection-fontsrecommended
        wrapfig
        minted
        fvextra
        upquote
        catchfile
        xstring
        framed
        titling ;
    };
  };
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

  xdg.userDirs = {
    enable = true;
    desktop = "$HOME/.desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Documents/Share";
    templates = "$HOME/Documents/Templates";
    videos = "$HOME/Videos";
  };

  gtk = {
    enable = true;
    font ={
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
      size = 10;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 0; };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.mu.enable = true;
  accounts.email = {
    accounts =
      let
        makeGmailAccount = { address, signature ? "" }:
          {
            address = address;
            realName = "Henry Fiantaca";
            signature = {
              showSignature = "append";
              text = signature;
            };
            userName = address;
            passwordCommand = "secret-tool lookup app-pwd ${address}";
            flavor = "gmail.com";
            mbsync = {
              enable = true;
              create = "maildir";
            };
            msmtp.enable = true;
            mu.enable = true;
          };
      in
        {
          "gmail" = (makeGmailAccount {
            address = "hfiantaca@gmail.com";
            signature = ''
  
            -- Henry Fiantaca
            '';
          } // { primary = true; });
          "uncc" = makeGmailAccount {
            address = "hfiantac@uncc.edu";
            signature = ''
  
            -- Henry Fiantaca
              801075065
              Undergraduate of CCI
            '';
          };
        };
    maildirBasePath = "/home/blasting/.local/share/maildir";
  };

  programs.mpv = {
    enable = true;
  };

  programs.qutebrowser = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      forceWayland = true;
    };
  };
  
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
      obs-gstreamer
      obs-v4l2sink
      obs-wlrobs
    ];
  };
}

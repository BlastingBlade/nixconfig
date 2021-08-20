{ lib, pkgs, ... }:

{
  imports = [ ./blasting.server.nix ];

  home.packages = with pkgs; [
    buildah

    lutris

    freecad
    prusa-slicer
  ];

  # lutris needs steam for integration
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-runtime"
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

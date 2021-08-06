{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    buildah
  ];

  programs.bash = {
    enable = true;
    enableVteIntegration = true;
    historyControl = [ "erasedups" "erasedups" ];
    shellAliases = {
      ll = "ls -l";
    };
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };
  programs.git = {
    enable = true;
    userName  = "Henry Fiantaca";
    userEmail = "hfiantaca@gmail.com";
  };
  
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
  
  programs.man = {
    enable = true;
    generateCaches = true;
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
    font ={
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
      size = 10;
    };
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
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
        makeGmailAccount = a:
          {
            address = a.address;
            realName = "Henry Fiantaca";
            signature = {
              showSignature = "append";
              text = a.signature;
            };
            userName = a.address;
            passwordCommand = "secret-tool lookup app-pwd ${a.address}";
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
          "gmail" = ( { primary = true; } // makeGmailAccount {
            address = "hfiantaca@gmail.com";
            signature = ''
  
            -- Henry Fiantaca
            '';
          });
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
    #maildirBasePath = "${home.homeDirectory}/.local/share/maildir";
  };

  programs.mpv = {
    enable = true;
  };

  programs.qutebrowser = {
    enable = true;
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

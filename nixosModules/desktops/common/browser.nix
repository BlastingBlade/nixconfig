{ config, lib, pkgs, self, ... }:

with lib;

let
  myFirefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    # nixExtensions
    extraPolicies = {
      DisableFirefoxScreenshots = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableSystemAddonUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      EncryptedMediaExtensions = {
        Enabled = false;
        Locked = true;
      };
      HardwareAcceleration = true;
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      FirefoxHome = {
        Search = true;
        TopSites = false;
        Highlights = false;
        Pocket = false;
        Snippets = false;
        Locked = true;
      };
      UserMessaging = {
        WhatsNew = false;
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        SkipOnboarding = true;
      };
    };
    forceWayland = true;
  };
in {
  environment.systemPackages = with pkgs; [
    myFirefox
    pkgs.gnome.epiphany
    pkgs.qutebrowser
  ];
}

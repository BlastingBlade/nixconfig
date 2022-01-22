{ config, lib, pkgs, self, ... }:

with lib;

let
  inherit (self.lib) mkEnableDefault;
  cfg = config.blasting.desktop.interception-tools;
in {
  options.blasting.desktop.interception-tools = {
    caps2esc = {
      enable = mkEnableDefault "Use Interception Tools to remap capslock to ctrl/esc";
      events = mkOption {
        type = with types; nullOr str;
        description = "DEVICE: EVENTS to send to caps2esc";
        default = "EV_KEY: [KEY_CAPSLOCK, KEY_ESC]";
      };
      devices = mkOption {
        type = with types; listOf str;
        description = "DEVICE: LINK to send to caps2esc";
        default = [];
        example = literalExample "[ \"/dev/input/by-path/platform-i8042-serio-0-event-kbd\" ]";
      };
    };
  };

  config = mkIf cfg.caps2esc.enable {
    services.interception-tools = {
      enable = true;
      plugins = [ pkgs.interception-tools-plugins.caps2esc ];
      udevmonConfig = let
        intercept_bin = "${pkgs.interception-tools}/bin/intercept";
        caps2esc_bin = "${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc";
        uinput_bin = "${pkgs.interception-tools}/bin/uinput";

        eventFmt = event:
          ''
            - JOB: ${intercept_bin} -g $DEVNODE | ${caps2esc_bin} | ${uinput_bin} -d $DEVNODE
              DEVICE:
                EVENTS:
                  ${event}
          '';
        eventRule = optional
          (cfg.caps2esc.events != null)
          (eventFmt caps2esc.events);

        deviceFmt = device:
          ''
            - JOB: ${intercept_bin} -g $DEVNODE | ${caps2esc_bin} | ${uinput_bin} -d $DEVNODE
              DEVICE:
                LINK: ${device}
          '';
        deviceRules =
          (map deviceFmt cfg.caps2esc.devices);

      in concatStringsSep "\n" (flatten [ eventRule deviceRules ]);
    };
  };
}

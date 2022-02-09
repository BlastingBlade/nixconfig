{
  enable = true;
  systemd.enable = true;
  style = ./waybar.css;
  settings = [{
    layer = "top";
    position = "top";
    output = [ "eDP-1" ];
    margin = "0px 6px 6px";

    modules-left = [ "river/tags" ];
    modules-center = [ "clock" ];
    modules-right = [
      "tray"
      "network#wifi"
      "network#eth"
      "disk#nix"
      "disk#home"
      "backlight"
      "idle_inhibitor"
      "pulseaudio"
      "battery"
    ];

    modules = {
      "clock" = {
        format = "{:%a %b %d, %H:%M}";
        tooltip = false;
      };
      "network#wifi" = {
        interface = "wlp6s0";
        format-disconnected = " --";
        format = "{icon} {essid}";
        format-icons = [ "" ];
        tooltip = false;
      };
      "network#eth" = {
        interface = "enp7s0";
        format-disconnected = "";
        format = " {ipaddr}";
        tooltip = false;
      };
      "disk#nix" = {
        format = " {percentage_free}%";
        path = "/nix";
        states = {
          "critical" = 100;
          "low" = 90;
          "good" = 75;
        };
        tooltip = false;
      };
      "disk#home" = {
        format = " {percentage_free}%";
        path = "/home";
        states = {
          "critical" = 100;
          "low" = 90;
          "good" = 75;
        };
        tooltip = false;
      };
      "backlight" = { format = " {percent}%"; };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          "deactivated" = "";
          "activated" = "";
        };
        tooltip = false;
      };
      "pulseaudio" = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{icon} {desc} {volume}% {format_source}";
        format-muted = "{icon} -- {format_source}";

        format-source = " {volume}%";
        format-source-muted = " --";

        format-icons = {
          "default" = "";
          "speaker" = "";
          "headphone" = "";
          "headset" = "";
        };

        tooltip = false;
      };
      "battery" = {
        bat = "BAT0";
        adapter = "AC";

        states = {
          full = 100;
          normal = 90;
          warning = 30;
          critical = 15;
        };

        format = "{icon} {capacity}%";
        format-charging = "{icon} {capacity}%";
        format-full = "";
        format-icons = [ "" "" "" "" "" ];
        tooltip = false;
      };
    };
  }];
}

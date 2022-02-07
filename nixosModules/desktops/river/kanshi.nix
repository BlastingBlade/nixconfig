{
  enable = true;
  systemdTarget = "graphical-session.target";
  profiles = {
    "standalone" = {
      # TODO exec = enable screensaver
      outputs = [
        {
          criteria = "eDP-1";
          mode = "1366x768@60Hz";
          position = "0,0";
        }
      ];
    };
    "docked" = {
      # TODO exec = disable screensaver
      outputs = [
        {
          criteria = "eDP-1";
          mode = "1366x768@60Hz";
          position = "0,0";
        }
        {
          criteria = "*";
          # to the right of
          position = "1366,0";
        }
      ];
    };
  };
}

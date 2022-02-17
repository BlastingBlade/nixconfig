{ pkgs, cfg'h }:
let
  # TODO: colorize swaylock
  lock = pkgs.writeShellScript "lockriver" ''
    ${pkgs.swaylock}/bin/swaylock \
      -f \
      -F \
      --image ${cfg'h.xdg.configHome}/oguri/wallpaper
  '';
  light = "${pkgs.light}/bin/light";
  light-darken = ''${light} -O && ${light} -S 5'';
  light-return = ''${light} -I'';
in {
  enable = true;
  events = [
    {
      event = "before-sleep";
      command = "${lock}";
    }
    {
      event = "after-resume";
      command = "${light-return}";
    }
  ];
  timeouts = [
    {
      timeout = (60 * 10);
      command = "${lock}";
    }
    {
      timeout = (60 * 13);
      command = "systemctl suspend";
    }
    {
      timeout = (60 * 7);
      command = "${light-darken}";
      resumeCommand = "${light-return}";
    }
  ];
}

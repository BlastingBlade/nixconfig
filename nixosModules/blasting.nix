{ config, lib, pkgs, ... }:

{
  time.timeZone = "America/New_York";
  blasting = {
    user = {
      username = "blasting";
      realname = "Henry Fiantaca";
      sshAuthorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmKlAu/Fgvt5TYZgBV3aZdoTQ+SfI/x+0zUEsyK9ET1 hfiantaca@gmail.com"
      ];
      passwordHash =
        "$6$jTnBoykh2C$c3xA1b0jHixv6WeFIQCmQ0Vc1l.N.l5Uc0t7/d.WPbkd8vERnWjZv8ZgGPNshPr3cME.RXGiOe5oi5hm2ym/q1";
    };
  };
}

{ config, pkgs, user, lib, ... }:

{
  systemd.user.startServices = "sd-switch";
  
  systemd.user.services.hello = {
    Unit = { Description = "chatty machine"; };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        echo "Good morning, ${user}!"
      '';
    };
  };
  
  systemd.user.timers.hello = {
    Unit = { Description = "hello hello"; };
    Timer = {
      OnCalendar = "*-*-* *:*:00";
      Unit = "hello.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };
}

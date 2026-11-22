{ config, pkgs, ... }:

{
  # Closing the lid always sleeps (AC or battery), unless an external display
  # is connected. Sleep = suspend first, then hibernate once on battery, so a
  # lid closed on AC and unplugged afterwards no longer sits in suspend until
  # the battery is empty.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";      # time in suspend (on battery) before hibernating
    HibernateOnACPower = false;    # while plugged in, stay suspended; countdown starts after unplug
    HibernateMode = "shutdown";    # power fully off after writing the image (instead of ACPI S4)
  };

  home-manager.users.user.programs.plasma.powerdevil =
    let
      lid = {
        whenLaptopLidClosed = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
        inhibitLidActionWhenExternalMonitorConnected = true;
      };
    in
    {
      AC = lid;
      battery = lid;
      lowBattery = lid;
    };
}

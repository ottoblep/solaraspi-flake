{ config, pkgs, lib, ... }:

{
  imports = [ ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  users = {
      users = {
        root = {
          password = "TestPW";
        };
      };
      mutableUsers = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;[
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


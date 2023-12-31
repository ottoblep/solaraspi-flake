{ config, pkgs, lib, ... }:

{
  imports = [ ];

  system.autoUpgrade = {
    enable = true;
    flake = "github:ottoblep/solaraspi-flake";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking = {
    hostName = "solaraspi";
    domain = "solaraspi.local";
    wireless = {
      enable = true;
      networks = {
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 1883 ]; # ssh and avahi are opened automatically
    };
  };

  services.avahi = {
    nssmdns = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "homedata"
    ];
    ensureUsers = 
    [
      {
        name = "sevi";
        ensurePermissions = {
          "DATABASE \"homedata\"" = "ALL PRIVILEGES";
        };
      }
    ];
    initialScript = ./database_init.sql;
  };
  # Request from script psql -d homedata -c "SELECT * FROM timesheet;"

  # MQTT to SQL Service
  systemd.services = {
    mqtt-sql-pipe = {
      enable = true;
      # For every new mqtt message enter the current timestamp into sql
      script = 
      "/run/current-system/sw/bin/mosquitto_sub -h 127.0.0.1 -q 2 -t home/lightswitched |
      xargs -n 1 /run/current-system/sw/bin/psql -d homedata -U sevi -c 'INSERT INTO timesheet VALUES (CURRENT_TIMESTAMP)'";
      serviceConfig = {
        User = "sevi";
        Restart = "always";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  users = let
    sevi-key = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpZOwdinQQ8yxfbfe0fASggxkvOdC3dETtxcP2AGbY1DxdVX8EijGSvORN+FIf+JZlS9bvg48UWZOLYHVbWyVnv9M5bPgK8OKgjD/HT5oiIXtCJKtFveroZyc8L9cOadZRBGYoOQrRfMKAnUC1wp1aw5gSAIC5+JPrb+OjKoRwXYwRv+mtXQw+E6DO8nAsVZ8B7u+NyHwYF7uSR+Gl8hbaBriiGlSe0gqIxGNq7CafYZ9uR2wbVZRX8k+mga7gHogY1KaCUmagNG3jDd/d/NIobzO0FJBbPg5J01dGfSOg0EljAlxywLxCERwbtNakHAgsq9qenBgc4wIgiKz/LqmV Sevis SSH Key" ];
  in {
      users = {
        root = {
          openssh.authorizedKeys.keys = sevi-key;
        };
        sevi = {
          isNormalUser = true;
          group = "users";
          home = "/home/sevi";
          openssh.authorizedKeys.keys = sevi-key;
        };
      };
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;[
    vim 
    git
    htop
    wget
    ripgrep
    fd
    tree
    file
    zoxide
    tio
    mosquitto
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
    };
   ohMyZsh = {
      enable = true;
      plugins = [ "git" "fd" "zoxide" "ripgrep" ];
      theme = "gozilla";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


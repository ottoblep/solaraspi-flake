{ config, pkgs, ... }:

{
  imports = [ ];

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

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    config = {
      homeassistant = {
        name = "Solaraspi";
        unit_system = "metric";
        time_zone = "Europe/Berlin";
      };

      frontend = {
        themes = "!include_dir_merge_named themes";
      };

      http = {};
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
    configWritable = true; # enable for testing settings
    extraComponents = 
    [
      "analytics"
      "default_config"
      "mqtt"
      "esphome"
      "my"
      "rpi_power"
    ];
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


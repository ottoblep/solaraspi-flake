{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };
  outputs = { nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    lib = nixpkgs.lib;
  in rec
  {
    nixosConfigurations.solaraspi = lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit inputs;};

      modules = [
        {
          imports = [
            ./modules/sd-image-aarch64-rauc
            ./configuration.nix
          ];
          sdImage = {
            imageBaseName = "nixos-raspi-rauc-sd-image";
            compressImage = false;
            expandOnBoot = false;
          };

          boot.kernelParams = lib.mkOverride 0 [ "console=ttyS1,115200" "console=tty1" ]; # Enable serial console on pins 8,10
          nix.extraOptions = ''experimental-features = nix-command flakes'';
        }
      ];
    };

    rootfs = nixosConfigurations.solaraspi.config.system.build.toplevel;
    image = nixosConfigurations.solaraspi.config.system.build.sdImage;
    uboot = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi3_64bit;
  };
}
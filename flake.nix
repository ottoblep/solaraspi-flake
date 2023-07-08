{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };
  outputs = { nixpkgs, ... }:
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

        modules = [
          {
            imports = [
              # https://nixos.wiki/wiki/NixOS_on_ARM#Build_your_own_image
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./configuration.nix
            ];

            boot.kernelParams = lib.mkOverride 0 [ "console=ttyS1,115200" "console=tty1" ]; # Enable serial console on pins 8,10
            nix.extraOptions = ''experimental-features = nix-command flakes'';
          }
        ];
    };

    solaraspi-image = nixosConfigurations.solaraspi.config.system.build.sdImage;
  };
}
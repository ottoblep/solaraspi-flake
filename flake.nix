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
      nixosConfigurations.rpi4 = lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          {
            imports = [
              # https://nixos.wiki/wiki/NixOS_on_ARM#Build_your_own_image
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./configuration.nix
            ];
          }
        ];
    };

    solaraspi = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}
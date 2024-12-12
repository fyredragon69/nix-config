{
    nixConfig = {
     extra-substituters = [ "https://cache.nichi.co" "https://cache.ztier.in" ];
     extra-trusted-public-keys = [ "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=" "cache.ztier.link-1:3P5j2ZB9dNgFFFVkCQWT3mh0E+S3rIWtZvoql64UaXM=" ];
   };

  inputs.nixpkgs.url = "github:NickCao/nixpkgs/riscv";
  inputs.nixpkgs-native.url = "github:NickCao/nixpkgs/riscv";
  inputs.nixos-hardware.url = "github:nixos/nixos-hardware";

  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-native, ... }: rec {
    nixosConfigurations.nixos = nixpkgs-native.lib.nixosSystem {
      modules = [
        ({ config, lib, ... }: {
          imports = [
            "${nixos-hardware}/starfive/visionfive/v2/sd-image-installer.nix"
          ];
          # Enable nix binary cache and flakes.
          nix.settings = {
            substituters = [ "https://cache.nichi.co" "https://cache.ztier.in" ];
            trusted-public-keys = [ "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=" "cache.ztier.link-1:3P5j2ZB9dNgFFFVkCQWT3mh0E+S3rIWtZvoql64UaXM=" ];
            experimental-features = [ "nix-command" "flakes" ];
          };

          # AND configure networking
          networking.interfaces.end0.useDHCP = true;
          networking.interfaces.end1.useDHCP = true;

          # Additional configuration goes here

          sdImage.compressImage = false;

          nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";

          system.stateVersion = "24.11";
        })
      ];
    };
    packages.x86_64-linux.default = packages.sd-image;
    packages.x86_64-linux.sd-image = self.nixosConfigurations.nixos.config.system.build.sdImage;
  };
}

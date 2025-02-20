{
  description = "Home Manager configuration of Doge Two";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    nix-darwin = {
      url = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    hax-nur = {
      url = "github:ihaveamac/nur-packages/staging";
      # this is using nixos-unstable because of the kwin patch
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, jovian, nixos-unstable, nix-darwin
    , hax-nur, spicetify-nix, nixos-apple-silicon, nixos-hardware, raspberry-pi-nix, ... }:
    let
      r = {
        root = ./.;
        sys-configs = ./sys-configs;
        modules = ./modules;
      };
      mkSpecialArgs = (me: system: {
        inherit me inputs r;
        hax-nur = hax-nur.outputs.packages.${system};
      });
    in {
      homeConfigurations.awill = home-manager.lib.homeManagerConfiguration (let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      }); # homeConfigurations.awill
      darwinConfigurations = {
        "Mac-Mini-2" = nix-darwin.lib.darwinSystem (let
          me = "awill";
          system = "aarch64-darwin";
        in rec {
          inherit system;

          specialArgs = mkSpecialArgs me system;
          modules = [ ./cfg-jvms.nix ];
        });
      };

      nixosConfigurations.nixdeck = nixpkgs.lib.nixosSystem (let
        system = "x86_64-linux";
        #pkgs = nixpkgs.legacyPackages.${system};
      in {
        inherit system;

        modules = [
          ./sys-configs/nixos-nixdeck/hardware-configuration.nix
          ./sys-configs/nixos-nixdeck/configuration.nix
          jovian.nixosModules.jovian
          {
            jovian = {
              steam = {
                enable = true;
                autoStart = true;
                #desktopSession can be plasma or plasmawayland.
                desktopSession = "plasma";
                user = "deck";
              };
              devices.steamdeck = {
                enable = true;
                autoUpdate = true;
                enableGyroDsuService = true;
                enablePerfControlUdevRules = true;
                enableSoundSupport = true;
                enableControllerUdevRules = true;
                enableXorgRotation = true; # should play with this later...
              };
              decky-loader = { enable = false; };
            };
          }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.deck = { pkgs, ... }: {
                imports = [ ./home.nix ];

                home = {
                  username = pkgs.lib.mkForce "deck";
                  homeDirectory = pkgs.lib.mkForce /home/deck;
                };
                programs.home-manager.enable = pkgs.lib.mkForce false;
              };
            };
          }
        ];
      }); # nixosConfigurations.nixdeck
      nixosConfigurations.Probook-650 = nixpkgs.lib.nixosSystem (let
        system = "x86_64-linux";
        #pkgs = nixpkgs.legacyPackages.${system};
      in {
        inherit system;

        modules = [
          ./sys-configs/nixos-probook/hardware-configuration.nix
          ./sys-configs/nixos-probook/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.awill = { pkgs, ... }: {
                imports = [ ./home.nix ];

                home = {
                  username = pkgs.lib.mkForce "awill";
                  homeDirectory = pkgs.lib.mkForce /home/awill;
                };
                programs.home-manager.enable = pkgs.lib.mkForce false;
              };
            };
          }
        ];
      });

      nixosConfigurations.Orion = nixpkgs.lib.nixosSystem
        (let system = "aarch64-linux";
        in {
          inherit system;

          modules = [
            ./sys-configs/nixos-macmini/configuration.nix
            ./sys-configs/nixos-macmini/hardware-configuration.nix
            nixos-apple-silicon.nixosModules.apple-silicon-support
          ];
        }); # nixosConfigurations.asahi-Orion

      # nixosConfigurations.Framework
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem (let
        system = "x86_64-linux";
        #pkgs = nixpkgs.legacyPackages.${system};
      in {
        inherit system;

        specialArgs = mkSpecialArgs "awill" system;

        modules = [
          ./sys-configs/nixos-framework/hardware-configuration.nix
          ./sys-configs/nixos-framework/configuration.nix
          home-manager.nixosModules.home-manager
          spicetify-nix.nixosModules.default
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.awill = { pkgs, ... }: {
                imports = [ ./home.nix ];

                home = {
                  username = pkgs.lib.mkForce "awill";
                  homeDirectory = pkgs.lib.mkForce /home/awill;
                };
                programs.home-manager.enable = true;
              };
            };
          }
        ];
      }); # nixosConfigurations.Framework
            nixosConfigurations.pifour-nixos = nixpkgs.lib.nixosSystem (let
        system = "aarch64-linux";
        #pkgs = nixpkgs.legacyPackages.${system};
      in {
        inherit system;

        modules = [
          ./sys-configs/nixos-pifour/hardware-configuration.nix
          ./sys-configs/nixos-pifour/configuration.nix
          raspberry-pi-nix.nixosModules.raspberry-pi
        ];
      }); # nixosConfigurations.pifour-nixos
    };
}

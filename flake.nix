{
  description = "Home Manager configuration of Doge Two";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, jovian, ... }: {
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

    nixosConfigurations.nixdeck = nixpkgs.lib.nixosSystem (let
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages.${system};
    in {
      inherit system;

      modules = [
        ./nixos-nixdeck/hardware-configuration.nix
        ./nixos-nixdeck/configuration.nix
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
        ./nixos-probook/hardware-configuration.nix
        ./nixos-probook/configuration.nix
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
    }); # nixosConfigurations.Probook-650
  };
}

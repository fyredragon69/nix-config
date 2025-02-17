{ config, lib, pkgs, ... }:

{
  # Enable the systemd-boot bootloader.
  boot.loader.systemd-boot.enable = true;
  # Set configuration limit to 2 for space limits.
  boot.loader.systemd-boot.configurationLimit = 2;
  # Necessasry for modifying EFI variables.
  boot.loader.efi.canTouchEfiVariables = true;
  # Enable bootsplash. Defaults to BGRT.
  boot.plymouth.enable = true;
  # Set timezone.
  time.timeZone = "America/Toronto";
  # Set localizations.
  i18n.defaultLocale = "en_CA.UTF-8";
  # Enable flakes. "Experimental".
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Enable networking.
  networking.networkmanager.enable = true;
  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;}

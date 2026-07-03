{ config, pkgs, ... }:

{
  imports =
  [
   ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  # Networking.
  networking = {
    networkmanager.enable = true;
    hostName = "WOLF";
  };

  # Timezone and locale.
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Define user account.
  users.users."awill" = {
    isNormalUser = true;
    description = "Furry";
    extraGroups = [ "networkmanager" "wheel" "sudo" "video" "audio" ];
    packages = with pkgs; [];
  };

  # Enable nix command and flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Privilege escilation.
  security.sudo.enable = true;

  # Audio stuff.
  services.pipewire = {
    enable = true
    audio.enable = true;
    pulse.enable = true;
  };

  # System wide packages to install.
  environment.systemPackages = with pkgs; [
    curl
    chromium
    nano
    hyfetch
    fastfetch
    git
    less
    tree
  ];

  system.stateVersion = "26.05";
}

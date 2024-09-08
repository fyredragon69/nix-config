{ config, pkgs, lib, me, inputs, ... }:

let 
  myjava = pkgs.zulu21;
in
{
  imports = [
    ./cfg-jvms.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
    nano
    btop
    hyfetch
    
  ];
  
  environment.variables = {
    MANPATH = "/opt/homebrew/share/man\${MANPATH+:$MANPATH}:";
    PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/zfs/bin\${PATH+:$PATH}";
    INFOPATH = "/opt/homebrew/share/info:\${INFOPATH:-}";
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
    JAVA_HOME = "${myjava}/Contents/Home";
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/nix-config/nix-darwin-macmini/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

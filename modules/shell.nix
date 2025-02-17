{ config, lib, pkgs, me, ... }:

{
  environment.shellAliases = {
    l = "ls";
    ll = "ll -h";
    claer = "clear";
    clea = "clear";
    cls = "clear";
    nrvl = "sudo nixos-rebuild switch -v -L --flake .";
    nfu = "nix flake update --commit-lock-file";
  };

  users.users.${me}.shell = "zsh";
}

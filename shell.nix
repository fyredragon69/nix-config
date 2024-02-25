{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    (pkgs.python3Packages.callPackage ./deriv-firmtool.nix {})
  ];
}

{ flake-inputs, pkgs, config, ... }:
{
  imports = [
    ./config.nix
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
/*
  # registry entries
  nix.registry = {
    stable.flake = flake-inputs.nixpkgs;
    osUnstable.flake = flake-inputs.nixpkgs-unstable;
    unstable.flake = flake-inputs.nixpkgs-pkgs-unstable;
    master.flake = flake-inputs.nixpkgs-master;
    local.flake = flake-inputs.nixpkgs-local;
  };

  # nix path to correspond to my flakes
  nix.nixPath = [
    "nixpkgs=${flake-inputs.nixpkgs}"
    "unstable=${flake-inputs.nixpkgs-unstable}"
  ];
*/

}

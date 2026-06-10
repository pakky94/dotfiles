{ lib, pkgs, config, ... }:
with lib;
let cfg = config.pakky.programs.kubernetes; in
{
  home.packages = with pkgs; [
    k9s
    kubectl
    kubectx
    kubernetes-helm
    stern
  ];
}

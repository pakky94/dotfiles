{ lib, pkgs, config, ... }:
{
  pakky.home-manager.username = "pacchialat";

  home.username = "pacchialat";
  home.homeDirectory = "/home/pacchialat";

  home.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.packages = with pkgs; [
  ];

  home.file = {
  };

  home.sessionVariables = {
    SUDO_EDITOR = "/home/${config.pakky.home-manager.username}/.nix-profile/bin/nvim";
  };

  programs.home-manager.enable = true;

  pakky = {
    programs = {
      atuin.enable = true;

      git = {
        enable = true;
        profile = "work";
      };

      kubernetes.enable = true;
      nvim.enable = true;
      starship.enable = true;
      zellij.enable = true;

      zsh = {
        default = true;
        enable = true;
      };
    };
  };

  imports = [
    ../modules
    ../scripts
    ./common/development.nix
    ./common/wsl-gui-fixes.nix
  ];
}

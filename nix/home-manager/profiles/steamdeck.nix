{ lib, pkgs, config, ... }:
{
  pakky.home-manager.username = "deck";

  home.username = "deck";
  home.homeDirectory = "/home/deck";
  pakky.nixConfigDir = "/home/deck/.local/share/chezmoi/nix";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.zsh.initExtraFirst = ". /home/${config.pakky.home-manager.username}/.nix-profile/etc/profile.d/nix.sh";

  home.packages = with pkgs; [
    atac
    cargo
    cmake
    entr
    gcc
    go
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
        profile = "personal";
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
  ];
}

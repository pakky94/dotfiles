{ lib, pkgs, config, ... }:
{
  pakky.home-manager.username = "pakky";

  home.username = "pakky";
  home.homeDirectory = "/home/pakky";
  pakky.nixConfigDir = "/home/pakky/p/dotfiles/nix";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  nix = {
    package = pkgs.nix;
#    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = with pkgs; [
    atac
    cargo
    cmake
    devbox
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
        overrideGitSsh = true;
        profile = "personal";
      };

      # kubernetes.enable = true;
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
    ../profiles/common/development.nix
  ];
}

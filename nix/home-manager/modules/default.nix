{ lib, pkgs, config, ... }:
{
 config.programs.ripgrep.enable = true;

 config.services.ssh-agent.enable = true;

 config.home.packages = [ pkgs.chezmoi ];

 imports = [
 ./atuin
 ./git
 ./hyprland
 ./kitty
 ./kubernetes
 ./nushell
 ./nvim
 ./starship
 ./tmux
 ./wezterm
 ./zellij
 ./zsh
 ];
}

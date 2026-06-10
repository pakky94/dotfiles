{ config, pkgs, lib, flake-self, home-manager, ... }:
with lib;
{
  options.pakky.home-manager = {
    username = mkOption {
      type = types.str;
      default = "pakky";
      description = "Main user";
      example = "marco";
    };
  };

  options.pakky.nixConfigDir = mkOption {
    type = types.str;
    default = "/home/pakky/.local/share/chezmoi/nix";
    description = "Dir of nix-config repo";
  };

  options.pakky.hostName = mkOption {
      type = types.str;
      default = "none";
      description = "Host name";
      example = "steamdeck | winmax2";
  };


  options.pakky.programs.atuin.enable = mkEnableOption "Setup atuin";

  options.pakky.programs.git.enable = mkEnableOption "Setup git";
  options.pakky.programs.git.overrideGitSsh = mkEnableOption "Setup git";
  options.pakky.programs.git.profile = mkOption {
      type = types.str;
      default = "personal";
      description = "Git profile to use";
      example = "personal | work";
  };

  options.pakky.programs.kitty.enable = mkEnableOption "Setup kitty";

  options.pakky.programs.kubernetes.enable = mkEnableOption "Setup kubernetes tools";

  options.pakky.programs.hyprland.enable = mkEnableOption "Setup hyprland";

  options.pakky.programs.nushell.default = mkEnableOption "Use nushell as default shell";
  options.pakky.programs.nushell.enable = mkEnableOption "Setup nushell";

  options.pakky.programs.nvim.enable = mkEnableOption "Setup neovim";

  options.pakky.programs.starship.enable = mkEnableOption "Setup starship";

  options.pakky.programs.tmux.enable = mkEnableOption "Setup tmux";

  options.pakky.programs.wezterm.enable = mkEnableOption "Setup wezterm";
  options.pakky.programs.zellij.enable = mkEnableOption "Setup zellij";

  options.pakky.programs.zsh.default = mkEnableOption "Use zsh as default shell";
  options.pakky.programs.zsh.enable = mkEnableOption "Setup zsh";

}

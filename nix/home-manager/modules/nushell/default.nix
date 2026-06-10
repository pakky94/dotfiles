{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.pakky;
in
{
  config = mkIf cfg.programs.nushell.enable {
    programs.nushell = {
      enable = true;

      shellAliases = {
        lg = "lazygit";
      };

      extraConfig = ''
$env.config.show_banner = false

$env.PATH = ($env.PATH | split row (char esep) | append $'($env.HOME)/.nix-profile/bin' | append '/nix/var/nix/profiles/default/bin' | uniq)

$env.config.edit_mode = 'vi'
$env.config.buffer_editor = "nvim"
$env.EDITOR = 'nvim'
      '';
    };

    programs.carapace = {
      enable = true;

      enableNushellIntegration = true;
    };
  };
}

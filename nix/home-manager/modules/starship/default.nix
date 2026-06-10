{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.pakky;
in
{
  config = mkIf cfg.programs.starship.enable {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        character = {
          format = "$symbol ";
          success_symbol = "[|>](bold green)";
          error_symbol = "[|>](bold red)";
        };
        directory = {
          truncate_to_repo = false;
        };
      };
    };
  };
}

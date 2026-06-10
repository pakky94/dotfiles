{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.pakky;
in
{
  config = mkIf cfg.programs.atuin.enable {
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        style = "compact";
        inline_height = 15;
        invert = true;
      };
    };
  };
}

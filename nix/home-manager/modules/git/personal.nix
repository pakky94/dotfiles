{ lib, pkgs, config, ... }:
with lib;
let cfg = config.pakky.programs.git; in
{
  config = mkIf (cfg.enable && cfg.profile == "personal") {
    programs = {
      git = {
        settings.user.email = "marco@pacchialat.com";
        settings.user.name = "Marco Pacchialat";
      };
    };
  };
}

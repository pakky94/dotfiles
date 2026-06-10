{ lib, config, ... }:
with lib;
{
 config = mkIf config.pakky.programs.wezterm.enable {
 programs.wezterm.enable = true;
 };
}

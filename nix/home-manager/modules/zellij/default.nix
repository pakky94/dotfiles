{ lib, config, ... }:
with lib;
{
 config = mkIf config.pakky.programs.zellij.enable {
 programs.zellij.enable = true;
 };
}

{ lib, pkgs, config, ... }:
with lib;
let
 cfg = config.pakky.programs.nvim;
in
{
 config = mkIf cfg.enable {
 programs.neovim = {
 enable = true;
 package = pkgs.neovim-unwrapped;

 defaultEditor = true;

 withPython3 = true;
 };
 };
}

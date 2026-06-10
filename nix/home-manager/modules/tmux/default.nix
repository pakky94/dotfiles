{ lib, config, ... }:
with lib;
let
  cfg = config.pakky;
in
{
  config = mkIf cfg.programs.tmux.enable {
    programs.tmux = {
      enable = true;
      historyLimit = 100000;
      extraConfig = ''
# remap prefix to Control + a
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# quick pane cycling
#unbind ^A
#bind ^A select-pane -t :.+
      '';
    };
  };
}

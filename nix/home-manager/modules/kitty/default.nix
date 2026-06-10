{ lib, pkgs, config, ... }:
with lib;
{
  config = mkIf config.pakky.programs.kitty.enable {
    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
        font_family = "'CaskaydiaCove NF'";

        confirm_os_window_close = 0;
        # dynamic_background_opacity = true;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
        # window_padding_width = 5;
        # background_opacity = "0.5";
        # background_blur = 5;
        foreground = "#979eab";
        background = "#282c34";
        cursor = "#cccccc";
        color0 = "#282c34";
        color1 = "#e06c75";
        color2 = "#98c379";
        color3 = "#e5c07b";
        color4 = "#61afef";
        color5 = "#be5046";
        color6 = "#56b6c2";
        color7 = "#979eab";
        color8 = "#393e48";
        color9 = "#d19a66";
        color10 = "#56b6c2";
        color11 = "#e5c07b";
        color12 = "#61afef";
        color13 = "#be5046";
        color14 = "#56b6c2";
        color15 = "#abb2bf";
        selection_foreground = "#282c34";
        selection_background = "#979eab";
      };
    };
  };
}

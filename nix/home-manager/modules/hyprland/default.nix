{ config, lib, ... }:
with lib;
let
  configDir = "${config.pakky.nixConfigDir}/home-manager/configs";
in
{
  config = mkIf config.pakky.programs.hyprland.enable {
    xdg.configFile."hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/hyprland.conf";

    xdg.configFile."hypr/monitors.conf".source =
      if config.pakky.hostName == "steamdeck" then
        config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/monitors_steamdeck.conf"
      else if config.pakky.hostName == "winmax2" then
        config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/monitors_winmax2.conf"
      else
        config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/monitors.conf";

    xdg.configFile."hypr/hyprlock.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/hyprlock.conf";

    xdg.configFile."waybar/config".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/waybar/config";

    xdg.configFile."waybar/power_menu.xml".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/waybar/power_menu.xml";

    xdg.configFile."rofi/config.rasi".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/rofi/config.rasi";

    xdg.configFile."wlogout" = {
      source = config.lib.file.mkOutOfStoreSymlink "${configDir}/wlogout";
      recursive = true;
    };
  };
}

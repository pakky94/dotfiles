{ pkgs, ... }:
{
  config.home.packages = with pkgs; [
    chromium
    keepassxc
    obs-studio
    # stremio
    unzip
    vlc
    ytdownloader
  ];
}

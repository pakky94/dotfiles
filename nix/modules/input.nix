{ pkgs, ... }:
{
  /*
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };
  */
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-anthy
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-with-addons
      fcitx5-m17n
    ];
  };
}

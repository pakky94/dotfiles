{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      font-awesome
      jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  # allow steam to load fonts
  system.userActivationScripts.linktosharedfolder.text = ''
if [[ ! -h "$HOME/.local/share/fonts" ]]; then
  ln -s "/run/current-system/sw/share/X11/fonts" "$HOME/.local/share/fonts"
fi
  '';
}

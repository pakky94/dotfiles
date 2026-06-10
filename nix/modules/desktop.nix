{ pkgs, inputs, ... }:
{
  config.services.flatpak.enable = true;
  config.systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  config.programs.firefox.enable = true;

  # config.environment.systemPackages = [
  #   inputs.zen-browser.packages."${pkgs.system}".default
  # ];
}

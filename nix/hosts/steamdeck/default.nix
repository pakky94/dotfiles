{ lib, pkgs, ... }:
let
  myUsername = "pakky";
  myUserdescription = "Marco Pacchialat";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
    ../../modules/fonts.nix
    ../../modules/hyprland.nix
    ../../modules/input.nix
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  jovian = {
    steam.enable = true;
    devices.steamdeck = {
      enable = true;
    };
  };

  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin];
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # services.desktopManager.plasma6.enable = true;
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  services.syncthing = {
    enable = true;
    user = "${myUsername}";
    dataDir = "/home/${myUsername}/Sync";    # Default folder for new synced folders
    configDir = "/home/${myUsername}/Sync/.config/syncthing";   # Folder for Syncthing's settings and keys
  };

  programs = {
    zsh.enable = true;
  };

  # Create user
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = myUserdescription;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      filezilla
      qbittorrent
    ];
  };

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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    dconf-editor
    gimp
    git
    gnomeExtensions.dock-from-dash
    gnomeExtensions.kimpanel
    gnome-terminal
    gnome-tweaks
    jupiter-dock-updater-bin
    lutris
    maliit-keyboard
    onboard
    openscad
    steamdeck-firmware
    usbutils

    remmina
    poppler-utils
    foo2zjs
  ];

  services.xserver.xkb.layout = "us";
  time.timeZone = "Europe/Rome";

  system.stateVersion = "24.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };
}

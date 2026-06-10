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
    # ../../modules/podman.nix
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.config.allowUnfree = true;
  # boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.kernelPackages = pkgs.linuxPackages_latest;
  virtualisation.vmware.guest.enable = true;

  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs = {
    zsh.enable = true;
  };

  # Create user
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = myUserdescription;
    extraGroups = [ "podman" "video" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    git
    gnomeExtensions.appindicator
    gnomeExtensions.dock-from-dash
    gnomeExtensions.kimpanel
    gnome-terminal
    gnome-tweaks
    usbutils
    poppler-utils
    foo2zjs
  ];

  services.udev.packages = with pkgs; [
    gnome-settings-daemon
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

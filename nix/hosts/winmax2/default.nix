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
    ../../modules/podman.nix
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # jovian = {
  #   steam.enable = true;
  #   devices.steamdeck = {
  #     enable = true;
  #   };
  # };

  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplipWithPlugin];
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.videoDrivers = [ "modesettings" "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # extraPackages = with pkgs; [
    #   amdvlk
    # ];
    #
    # extraPackages32 = with pkgs; [
    #   driversi686Linux.amdvlk
    # ];
  };

  # hardware.amdgpu.initrd.enable = true;
  # hardware.amdgpu.amdvlk.enable = true;

  # services.desktopManager.plasma6.enable = true;
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;

      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };

  services.syncthing = {
    enable = true;
    user = "${myUsername}";
    dataDir = "/home/${myUsername}/Sync/Default";    # Default folder for new synced folders
    configDir = "/home/${myUsername}/Sync/.config/syncthing";   # Folder for Syncthing's settings and keys
  };

  programs = {
    zsh.enable = true;
  };

  # Create user
  users.users."${myUsername}" = {
    isNormalUser = true;
    description = myUserdescription;
    extraGroups = [ "podman" "video" "wheel" ];
    shell = pkgs.zsh;

    subGidRanges = [ {
      count = 65536;
      startGid = 1001;
    } ];

    subUidRanges = [ {
      count = 65536;
      startUid = 1001;
    } ];

    packages = with pkgs; [
      filezilla
      qbittorrent
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
    # jupiter-dock-updater-bin
    lutris
    maliit-keyboard
    onboard
    openscad
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

  services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chgrp input /sys/class/leds/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
'';
}

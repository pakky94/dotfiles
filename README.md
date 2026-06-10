# Dotfiles

Cross-platform dotfiles managed by [chezmoi](https://www.chezmoi.io/), plus a Nix flake (`flake.nix`) covering NixOS hosts (`steamdeck`, `vmware`, `winmax2`) and home-manager standalone profiles (`wsl-personal`, `wsl-work`, `steamdeck`, `winmax2hm`).

## Structure

- `dot_config/`, `dot_*` — chezmoi-managed dotfiles (Linux + Windows)
- `AppData/` — Windows-only chezmoi files (e.g. alacritty)
- `private_dot_local/` — Linux-only chezmoi files
- `flake.nix`, `flake.lock` — Nix flake at repo root
- `nix/` — NixOS modules, hosts, and home-manager modules/profiles

## Initialization

The nix flake installs the `chezmoi` binary via home-manager on every host and profile, so once nix is set up chezmoi is available on `PATH`.

On a fresh machine without nix yet, you can bootstrap chezmoi directly from nixpkgs:

```sh
nix run nixpkgs#chezmoi -- init pakky94
```

This creates the chezmoi working copy at `~/.local/share/chezmoi`. The nix config expects this path — see `nix/modules/config.nix` (`pakky.nixConfigDir`).

After initialization, deploy dotfiles with `chezmoi apply`.

## Font

CaskaydiaCove NF from [NerdFonts](https://www.nerdfonts.com/font-downloads)

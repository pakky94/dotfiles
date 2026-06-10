# Dotfiles

Cross-platform dotfiles managed by [chezmoi](https://www.chezmoi.io/), plus a Nix flake (`flake.nix`) covering NixOS hosts (`steamdeck`, `vmware`, `winmax2`) and home-manager standalone profiles (`wsl-personal`, `wsl-work`, `steamdeck`, `winmax2hm`).

## Structure

- `dot_config/`, `dot_*` — chezmoi-managed dotfiles (Linux + Windows)
- `AppData/` — Windows-only chezmoi files (e.g. alacritty)
- `private_dot_local/` — Linux-only chezmoi files
- `flake.nix`, `flake.lock` — Nix flake at repo root
- `nix/` — NixOS modules, hosts, and home-manager modules/profiles

## Font

CaskaydiaCove NF from [NerdFonts](https://www.nerdfonts.com/font-downloads)

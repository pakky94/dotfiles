# Merge nix-config into dotfiles

**Date:**2026-06-10
**Branch:** `merge-nix-config`
**Goal:** single repo containing both chezmoi-managed dotfiles (cross-platform) and the nix configuration (linux hosts).

## Final layout

```
~/p/dotfiles/
├── .chezmoiignore # updated
├── .chezmoitemplates/ # REMOVED (nvim consolidated)
├── AppData/ # REMOVED (nvim now via dot_config on both OSes)
│ └── Roaming/alacritty/ # kept (windows-only alacritty, was chezmoiignored on PC23015 anyway)
├── dot_config/
│ ├── nvim/ # populated from nix-config/modules/nvim/lua-config (no .tmpl)
│ │ ├── init.lua
│ │ ├── lazy-lock.json
│ │ └── lua/...
│ ├── zellij/ # populated from nix-config/modules/zellij/config (no .tmpl)
│ │ ├── config.kdl
│ │ └── layouts/...
│ └── private_mc/ # unchanged
├── dot_ideavimrc # replaced with nix-config version
├── dot_wezterm.lua.tmpl # unchanged
├── private_dot_local/ # unchanged
├── flake.nix # copied from nix-config/flake.nix (paths updated)
├── flake.lock # copied from nix-config/flake.lock
├── nix/ # everything from nix-config EXCEPT flake.nix/flake.lock
│ ├── hosts/{steamdeck,vmware,winmax2}/
│ ├── home-manager/
│ │ ├── configs/ # hypr/, rofi/, waybar/, wlogout/, ideavimrc
│ │ ├── modules/ # without nvim/zellij configs (only enable flags remain)
│ │ ├── profiles/ #5 .nix profiles
│ │ └── scripts/
│ └── modules/ # core.nix, config.nix, desktop.nix, etc.
├── README.md # merged
└── docs/plans/ # new
```

## Decisions (from user)

1. **Conflict winners:** nix-config is canonical for `zellij/config.kdl` and `dot_ideavimrc`.
2. **Wezterm:** chezmoi is canonical. Nix's `programs.wezterm` module gets stripped of `extraConfig` (becomes a no-op package install).
3. **Alacritty:** stays chezmoi-managed, Windows-only via `.chezmoiignore` on Linux.
4. **`nixConfigDir` paths:** update all6 occurrences from `/home/pakky/p/nix-config` → `/home/pakky/p/dotfiles/nix`. SteamDeck's `/home/deck/p/nix-config` → `/home/deck/p/dotfiles/nix`.
5. **Neovim Windows path:** consolidated to `~/.config/nvim` (via `$XDG_CONFIG_HOME` set by user on Windows). The `AppData/Local/nvim/` directory and templates get deleted.
6. **History:** not preserved — copy files from `~/p/nix-config` into the working tree.
7. **README:** merge both.

## .chezmoiignore updates

Current:
```
{{ if ne .chezmoi.os "linux" }}
.config
{{ else if ne .chezmoi.os "windows" }}
AppData
{{ end }}
{{ if eq .chezmoi.fqdnHostname "PC23015" }}
.wezterm.lua
AppData/Roaming/alacritty
{{ end }}
README.md
```

After:
```
{{ if ne .chezmoi.os "linux" }}
AppData
{{ else if ne .chezmoi.os "windows" }}
{{ end }}
{{ if eq .chezmoi.fqdnHostname "PC23015" }}
.wezterm.lua
AppData/Roaming/alacritty
{{ end }}
README.md
```

Rationale: since nvim/zellij now live only in `dot_config/`, the entire `.config/` directory should be deployed on **both** OSes. The old "if not linux, skip .config" rule was because the Windows neovim was in `AppData/Local/nvim/`; that's gone now. `AppData/` is still Linux-only (it contains Windows-only files like alacritty).

Actually wait — `AppData/Roaming/alacritty/` IS Windows-only, so AppData being linux-excluded stays correct. Let me restate:

- On **Linux**: deploy `dot_config/` (now contains nvim + zellij + mc), deploy `private_dot_local/`, deploy `dot_ideavimrc`, deploy `dot_wezterm.lua`, SKIP `AppData/`.
- On **Windows**: deploy `dot_config/` (now contains nvim + zellij + mc), deploy `AppData/` (alacritty), SKIP `private_dot_local/` (Linux user-only). `dot_wezterm.lua` is conditionally skipped on `PC23015`.

Final `.chezmoiignore`:
```
{{ if ne .chezmoi.os "linux" }}
AppData
{{ else if ne .chezmoi.os "windows" }}
private_dot_local
{{ end }}
{{ if eq .chezmoi.fqdnHostname "PC23015" }}
.wezterm.lua
AppData/Roaming/alacritty
{{ end }}
README.md
```

(The `private_dot_local` line already wasn't there but `private_*` files are explicitly private — chezmoi default behaviour already requires run-once handling. Adding explicit ignore is defensive.)

## Nix module changes

`nix/home-manager/modules/nvim/default.nix`:
- Remove `xdg.configFile.nvim_lua_config = { source = ./lua-config; recursive = true; }` block (chezmoi handles it now)
- Keep `programs.neovim = { enable = true; package = pkgs.neovim-unwrapped; defaultEditor = true; withPython3 = true; }`

`nix/home-manager/modules/zellij/default.nix`:
- Remove `xdg.configFile.zellij_config` block
- Keep `programs.zellij.enable = true`

`nix/home-manager/modules/wezterm/default.nix`:
- Strip the entire `extraConfig = ''...''` block (chezmoi owns the config file)
- Keep `programs.wezterm.enable = true`

`nix/home-manager/modules/default.nix`:
- The `xdg.configFile."ideavim/ideavimrc"` symlink should remain OR be removed since `dot_ideavimrc` now does the job. **Keep it** — this is for IntelliJ's `$XDG_CONFIG_HOME/ideavim/ideavimrc` location, separate from `~/.ideavimrc`. Both are valid IntelliJ config paths; home-manager symlink is the safe fallback. Actually — let me drop it. The user's chezmoi `dot_ideavimrc` deploys to `~/.ideavimrc` which IntelliJ picks up natively. Cleaner to drop the symlink and remove the dependency on `nixConfigDir`.

`nix/modules/config.nix`:
- `pakky.nixConfigDir` default: `/home/pakky/p/nix-config` → `/home/pakky/p/dotfiles/nix`

`nix/flake.nix`:
- All `./modules/...` and `./hosts/...` and `./home-manager/...` paths need `./nix/` prefix
- All `./home-manager/...` paths need `./nix/home-manager/...` prefix

`nix/hosts/*/home-manager.nix` and `nix/home-manager/profiles/*.nix`:
- `config.pakky.nixConfigDir = "/home/pakky/p/nix-config"` → `"/home/pakky/p/dotfiles/nix"`
- SteamDeck profile: `"/home/deck/p/nix-config"` → `"/home/deck/p/dotfiles/nix"`

## Migration steps (execution)

1. **Pre-flight:** confirm branch `merge-nix-config`, working tree clean ✓
2. **Copy nix-config files:**
 - `cp /home/pakky/p/nix-config/flake.nix ./flake.nix` (then edit paths)
 - `cp /home/pakky/p/nix-config/flake.lock ./flake.lock`
 - `cp -r /home/pakky/p/nix-config/modules ./nix-modules-tmp`
 - `cp -r /home/pakky/p/nix-config/hosts ./nix-hosts-tmp`
 - `cp -r /home/pakky/p/nix-config/home-manager ./nix-hm-tmp`
3. **Reorganize into `nix/`:**
 - `mkdir nix && mv nix-modules-tmp nix/modules && mv nix-hosts-tmp nix/hosts && mv nix-hm-tmp nix/home-manager`
4. **Move nvim config into chezmoi:**
 - `cp nix/home-manager/modules/nvim/lua-config/init.lua dot_config/nvim/init.lua`
 - `cp nix/home-manager/modules/nvim/lua-config/lua/*.lua dot_config/nvim/lua/`
 - `cp nix/home-manager/modules/nvim/lua-config/lua/plugins/*.lua dot_config/nvim/lua/plugins/`
 - `cp nix/home-manager/modules/nvim/lua-config/lua/languages/*.lua dot_config/nvim/lua/languages/`
 - `cp .chezmoitemplates/nvim/lazy-lock.json dot_config/nvim/lazy-lock.json` (preserves lock state)
 - Remove `dot_config/nvim/*.tmpl`, `AppData/Local/nvim/`, `.chezmoitemplates/nvim/`
5. **Move zellij config:**
 - `cp nix/home-manager/modules/zellij/config/config.kdl dot_config/zellij/config.kdl`
 - `cp -r nix/home-manager/modules/zellij/config/layouts dot_config/zellij/`
6. **Replace `dot_ideavimrc`:**
 - `cp nix/home-manager/configs/ideavimrc dot_ideavimrc`
7. **Update `.chezmoiignore`** (see above)
8. **Strip nix nvim/zellij config symlinks** (see above)
9. **Update `flake.nix` paths** (add `./nix/` prefix)
10. **Update `nixConfigDir` paths** in6 files
11. **Verify:**
 - `chezmoi diff` to see what changes chezmoi would apply
 - `nix flake check` (if user has nix available — optional, we can't run it without nix)
 - `git status` — review file moves
12. **Commit on `merge-nix-config`** in logical chunks (or single commit if user prefers)
13. **Merge to `master`** when ready

## Risk / known issues

- **Neovim lock file:** `lazy-lock.json` is dated to chezmoi state. After first launch on each machine, lazy.nvim may update it. Acceptable drift.
- **No `nix flake check` available** in this sandbox — the user should run it manually before merging to master.
- **WSL + NixOS paths in `nixConfigDir`:** the hardcoded `/home/pakky/p/dotfiles/nix` won't match WSL (`/home/pakky/...`) AND NixOS (`/home/pakky/...`) AND SteamDeck (`/home/deck/...`). The current pattern of overriding per-profile is preserved.
- **History loss:** user opted out of preserving nix-config history. Single import commit.

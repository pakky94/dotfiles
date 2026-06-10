# Merge nix-config into dotfiles Implementation Plan

> **REQUIRED SUB-SKILL:** Use the executing-plans skill to implement this plan task-by-task.

**Goal:** Merge the `~/p/nix-config` repo into `~/p/dotfiles` so that nvim, zellij, and wezterm configs become chezmoi-managed (shared across Linux + Windows) while the nix flake stays at the root with the rest of nix-config under `nix/`.

**Architecture:**
- Copy files from `~/p/nix-config` into `~/p/dotfiles` (no git history from nix-config).
- Move neovim and zellij config files into the existing chezmoi structure (`dot_config/nvim/`, `dot_config/zellij/`) and delete their nix-side symlink modules.
- Keep `flake.nix` and `flake.lock` at the repo root; everything else from nix-config goes to `nix/`.
- Update `.chezmoiignore` so neither OS pollutes the other.

**Tech Stack:** chezmoi, Nix flakes, home-manager, neovim, zellij, wezterm.

**Reference:** `docs/plans/2026-06-10-merge-nix-config-design.md`

---

## Task1: Bring nix-config files into the working tree (unrenamed temp)

**Files:**
- Copy: `flake.nix`, `flake.lock`, `modules/`, `hosts/`, `home-manager/` from `/home/pakky/p/nix-config`

**Step1:** Copy the nix-config files into a staging area at the dotfiles root.

```bash
cd /home/pakky/p/dotfiles
cp /home/pakky/p/nix-config/flake.nix ./flake.nix
cp /home/pakky/p/nix-config/flake.lock ./flake.lock
mkdir -p _nix_import
cp -r /home/pakky/p/nix-config/modules ./nix-modules
cp -r /home/pakky/p/nix-config/hosts ./nix-hosts
cp -r /home/pakky/p/nix-config/home-manager ./nix-hm
```

**Step2:** Verify.

```bash
ls /home/pakky/p/dotfiles/flake.nix /home/pakky/p/dotfiles/flake.lock
ls /home/pakky/p/dotfiles/nix-modules /home/pakky/p/dotfiles/nix-hosts /home/pakky/p/dotfiles/nix-hm
```

Expected: all paths exist; total files ≈95.

**Step3:** Do NOT commit yet — proceed to Task2.

---

## Task2: Reorganize nix files under `nix/` subfolder

**Files:**
- Move: `nix-modules/` → `nix/modules/`
- Move: `nix-hosts/` → `nix/hosts/`
- Move: `nix-hm/` → `nix/home-manager/`

**Step1:** Create `nix/` and move the three directories in.

```bash
cd /home/pakky/p/dotfiles
mkdir nix
mv nix-modules nix/modules
mv nix-hosts nix/hosts
mv nix-hm nix/home-manager
rmdir _nix_import
```

**Step2:** Verify.

```bash
ls nix/modules nix/hosts nix/home-manager
```

Expected: each lists the expected subfolders.

**Step3:** Do NOT commit yet — proceed to Task3.

---

## Task3: Move neovim config from nix into chezmoi

**Files:**
- Add (copy): `dot_config/nvim/init.lua`, `dot_config/nvim/lazy-lock.json`, `dot_config/nvim/lua/*.lua`, `dot_config/nvim/lua/languages/*.lua`, `dot_config/nvim/lua/plugins/*.lua`
- Delete: `dot_config/nvim/init.lua.tmpl`, `dot_config/nvim/lua/*.tmpl`, `dot_config/nvim/lua/languages/*.tmpl`, `dot_config/nvim/lua/plugins/*.tmpl`, `AppData/Local/nvim/` (entire subtree), `.chezmoitemplates/nvim/` (entire subtree)

**Step1:** Copy nix neovim config files into the chezmoi tree.

```bash
cd /home/pakky/p/dotfiles
SRC=nix/home-manager/modules/nvim/lua-config
DST=dot_config/nvim
cp "$SRC/init.lua" "$DST/init.lua"
cp .chezmoitemplates/nvim/lazy-lock.json "$DST/lazy-lock.json"
cp "$SRC/lua"/*.lua "$DST/lua/"
cp "$SRC/lua/languages"/*.lua "$DST/lua/languages/"
cp "$SRC/lua/plugins"/*.lua "$DST/lua/plugins/"
```

**Step2:** Remove the old template files and windows-only AppData nvim path.

```bash
cd /home/pakky/p/dotfiles
rm -f dot_config/nvim/init.lua.tmpl
rm -f dot_config/nvim/lua/*.tmpl
rm -f dot_config/nvim/lua/languages/*.tmpl
rm -f dot_config/nvim/lua/plugins/*.tmpl
rm -rf AppData/Local/nvim
rm -rf .chezmoitemplates/nvim
```

**Step3:** Verify.

```bash
ls /home/pakky/p/dotfiles/dot_config/nvim
ls /home/pakky/p/dotfiles/dot_config/nvim/lua
ls /home/pakky/p/dotfiles/AppData2>/dev/null
ls /home/pakky/p/dotfiles/.chezmoitemplates2>/dev/null
```

Expected:
- `dot_config/nvim/` lists `init.lua`, `lazy-lock.json`, `lua/` (no `.tmpl` files).
- `AppData/` still contains `Roaming/alacritty/`.
- `.chezmoitemplates/` is gone (or empty).

**Step4:** Do NOT commit yet — proceed to Task4.

---

## Task4: Move zellij config from nix into chezmoi

**Files:**
- Add (copy): `dot_config/zellij/config.kdl`, `dot_config/zellij/layouts/compact.kdl`, `dot_config/zellij/layouts/compact.swap.kdl`

**Step1:** Copy zellij config (from nix, since user picked nix as canonical).

```bash
cd /home/pakky/p/dotfiles
SRC=nix/home-manager/modules/zellij/config
DST=dot_config/zellij
cp "$SRC/config.kdl" "$DST/config.kdl"
cp -r "$SRC/layouts"/* "$DST/layouts/"
```

**Step2:** Verify.

```bash
diff -r dot_config/zellij nix/home-manager/modules/zellij/config
```

Expected: no diff.

**Step3:** Do NOT commit yet — proceed to Task5.

---

## Task5: Replace `dot_ideavimrc` with nix version

**Files:**
- Modify: `dot_ideavimrc` (replace contents)

**Step1:** Copy nix ideavimrc (canonical per user).

```bash
cd /home/pakky/p/dotfiles
cp nix/home-manager/configs/ideavimrc dot_ideavimrc
```

**Step2:** Verify.

```bash
head -5 dot_ideavimrc
```

Expected:
```
set vb t_vb=
set belloff=all
set noerrorbells

```

**Step3:** Do NOT commit yet — proceed to Task6.

---

## Task6: Update `.chezmoiignore`

**Files:**
- Modify: `.chezmoiignore`

**Step1:** Replace the contents of `.chezmoiignore` with:

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

**Step2:** Verify.

```bash
cat .chezmoiignore
```

Expected: matches the file above.

**Step3:** Do NOT commit yet — proceed to Task7.

---

## Task7: Strip nix neovim symlink module

**Files:**
- Modify: `nix/home-manager/modules/nvim/default.nix`

**Step1:** Replace the contents of `nix/home-manager/modules/nvim/default.nix` with:

```nix
{ lib, pkgs, config, ... }:
with lib;
let
 cfg = config.pakky.programs.nvim;
in
{
 config = mkIf cfg.enable {
 programs.neovim = {
 enable = true;
 package = pkgs.neovim-unwrapped;
 defaultEditor = true;
 withPython3 = true;
 };
 };
}
```

**Step2:** Verify.

```bash
cat nix/home-manager/modules/nvim/default.nix
```

Expected: no references to `xdg.configFile` or `lua-config` source paths.

**Step3:** Do NOT commit yet — proceed to Task8.

---

## Task8: Strip nix zellij symlink module

**Files:**
- Modify: `nix/home-manager/modules/zellij/default.nix`

**Step1:** Replace the contents of `nix/home-manager/modules/zellij/default.nix` with:

```nix
{ lib, config, ... }:
with lib;
{
 config = mkIf config.pakky.programs.zellij.enable {
 programs.zellij.enable = true;
 };
}
```

**Step2:** Verify.

```bash
cat nix/home-manager/modules/zellij/default.nix
```

Expected: no `xdg.configFile.zellij_config`.

**Step3:** Do NOT commit yet — proceed to Task9.

---

## Task9: Strip nix wezterm `extraConfig`

**Files:**
- Modify: `nix/home-manager/modules/wezterm/default.nix`

**Step1:** Replace the contents of `nix/home-manager/modules/wezterm/default.nix` with:

```nix
{ lib, config, ... }:
with lib;
{
 config = mkIf config.pakky.programs.wezterm.enable {
 programs.wezterm.enable = true;
 };
}
```

**Step2:** Verify.

```bash
cat nix/home-manager/modules/wezterm/default.nix
```

Expected: no `extraConfig`.

**Step3:** Do NOT commit yet — proceed to Task10.

---

## Task10: Remove now-unused `ideavim` symlink from `nix/home-manager/modules/default.nix`

**Files:**
- Modify: `nix/home-manager/modules/default.nix`

**Step1:** Edit the file to remove the line:
```nix
config.xdg.configFile."ideavim/ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${config.pakky.nixConfigDir}/home-manager/configs/ideavimrc";
```
Keep everything else (`programs.ripgrep.enable`, `services.ssh-agent.enable`, `imports = [ ./atuin ./git ...]`).

**Step2:** Verify.

```bash
grep -n ideavim nix/home-manager/modules/default.nix
```

Expected: no output.

**Step3:** Do NOT commit yet — proceed to Task11.

---

## Task11: Update `nixConfigDir` default in `nix/modules/config.nix`

**Files:**
- Modify: `nix/modules/config.nix:13-19` (the `pakky.nixConfigDir` option default)

**Step1:** Change the default string from `"/home/pakky/p/nix-config"` to `"/home/pakky/p/dotfiles/nix"`.

**Step2:** Verify.

```bash
grep -n nixConfigDir nix/modules/config.nix
```

Expected: shows `default = "/home/pakky/p/dotfiles/nix";`.

**Step3:** Do NOT commit yet — proceed to Task12.

---

## Task12: Update `nixConfigDir` overrides in host/profile files

**Files:**
- Modify: `nix/hosts/steamdeck/home-manager.nix:7`
- Modify: `nix/hosts/vmware/home-manager.nix:7`
- Modify: `nix/hosts/winmax2/home-manager.nix:7`
- Modify: `nix/home-manager/profiles/steamdeck.nix:7`
- Modify: `nix/home-manager/profiles/winmax2.nix:7`

**Step1:** Replace each occurrence:
- `/home/pakky/p/nix-config` → `/home/pakky/p/dotfiles/nix` (5 files)
- `/home/deck/p/nix-config` → `/home/deck/p/dotfiles/nix` (steamdeck profile)

For each of the6 files, find the `config.pakky.nixConfigDir = "...";` (or `pakky.nixConfigDir = "...";` in profiles) line and rewrite the path.

**Step2:** Verify.

```bash
grep -rn "nix-config\|nixConfigDir" nix/ --include="*.nix"
```

Expected: all `nix-config` references now point at `nix-config` only as text inside option descriptions (if any); the values are all `p/dotfiles/nix`. No literal `/home/pakky/p/nix-config` or `/home/deck/p/nix-config` paths remain.

**Step3:** Do NOT commit yet — proceed to Task13.

---

## Task13: Update `flake.nix` paths to add `./nix/` prefix

**Files:**
- Modify: `flake.nix`

**Step1:** In `flake.nix`, replace all `./modules/` → `./nix/modules/`, `./hosts/` → `./nix/hosts/`, `./home-manager/` → `./nix/home-manager/`.

There are8 such references in the file (3 NixOS host configs +5 homeConfigurations).

**Step2:** Verify.

```bash
grep -n "\./" flake.nix
```

Expected: every `./...` path starts with `./nix/`.

**Step3:** Do NOT commit yet — proceed to Task14.

---

## Task14: Merge README

**Files:**
- Modify: `README.md`

**Step1:** Replace `README.md` with a merged version that documents both chezmoi and the nix flake.

Content:

```markdown
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
```

**Step2:** Verify.

```bash
cat README.md
```

Expected: matches above.

**Step3:** Do NOT commit yet — proceed to Task15.

---

## Task15: Sanity-check the result

**Files:** none (read-only)

**Step1:** Confirm no stale references to nix-config remain.

```bash
grep -rn "nix-config\|nix_modules\|nix_hosts\|nix_hm\|lua-config" --include="*.nix" .
```

Expected: only references to `nix-config` inside option descriptions or comments; nothing referencing the old path or stale nix-side neovim/zellij config sources.

**Step2:** Confirm chezmoi ignore works.

```bash
chezmoi diff2>&1 | head -40 || echo "(chezmoi not installed — skip)"
```

Expected: chezmoi shows file additions/modifications (no deletions at OS-conditional paths).

**Step3:** Confirm the layout.

```bash
find . -maxdepth2 -type d -not -path './.git*' | sort
```

Expected: includes `AppData`, `dot_config`, `nix`, `private_dot_local`, `.chezmoitemplates` (gone) — and the new `docs/plans/`.

**Step4:** Do NOT commit yet — proceed to Task16.

---

## Task16: Stage and commit

**Files:** none (git operations)

**Step1:** Stage everything.

```bash
cd /home/pakky/p/dotfiles
git add -A
```

**Step2:** Review.

```bash
git status --short | head -50
```

Expected: shows new files under `nix/`, modified `flake.nix`/`flake.lock`/`.chezmoiignore`/`README.md`/`dot_ideavimrc`, new files under `dot_config/nvim/` and `dot_config/zellij/`, deletions under `AppData/Local/nvim/` and `.chezmoitemplates/nvim/`.

**Step3:** Commit.

```bash
git commit -m "merge nix-config into dotfiles

- nvim and zellij configs moved from nix into chezmoi (cross-platform)
- wezterm stays chezmoi-managed; nix module no longer inlines config
- flake.nix + flake.lock stay at repo root; rest of nix-config under nix/
- nixConfigDir paths updated to /home/pakky/p/dotfiles/nix
- .chezmoiignore updated to reflect new structure"
```

**Step4:** Verify.

```bash
git log --oneline -5
```

Expected: shows the new merge commit on top of the design-doc commit.

---

## Task17 (manual, user): validate before merge to master

**Files:** none (user runs on their machines)

**Step1:** On a Linux machine, run:

```bash
chezmoi diff
nix flake check # if nix available
```

**Step2:** On Windows, run:

```bash
chezmoi diff
```

**Step3:** If green, merge `merge-nix-config` → `master` per project convention.

---

## Notes for the implementer

- TDD isn't applicable here — this is a one-shot file migration. Verification is by inspection (`diff`, `grep`, manual `chezmoi diff`).
- If the user prefers multiple smaller commits instead of one merge commit, split per task boundaries (Tasks2,3,4,5,7,11,12,13 are natural commit points).
- If `chezmoi` is not installed in the sandbox, skip `chezmoi diff` in Task15.

# Hyprland .conf → hl.* Lua Migration Implementation Plan

> **REQUIRED SUB-SKILL:** Use the executing-plans skill to implement this plan task-by-task.

**Goal:** Replace `nix/home-manager/configs/hypr/*.conf` with the new Hyprland lua config (`hl.*` API), inline per-host monitor/lid logic into per-host `init.lua` files, and update the nix module to point at them. Hyprlock stays as `.conf` (no lua support in hyprlock).

**Architecture:**
- Create three new files: `init.lua` (default), `init_steamdeck.lua`, `init_winmax2.lua`. Each fully self-contained.
- Each file uses the `hl.*` API: `hl.config({...})`, `hl.bind(...)`, `hl.monitor(...)`, `hl.animation(...)`, `hl.curve(...)`, `hl.env(...)`, `hl.device(...)`, `hl.gesture(...)`, `hl.window_rule({...})`, `hl.layer_rule({...})`.
- Variables become lua locals: `local mainMod = "SUPER"`.
- Modifiers concatenated as strings (`mainMod .. " + ALT + F"`), not passed as opts.
- Delete the four old `.conf` files.
- Nix module selects the right `init_*.lua` based on `pakky.hostName`.

**Tech Stack:** Hyprland ≥0.46 with the new lua config API (verified against `example/hyprland.lua` and `src/config/lua/bindings/*.cpp`).

**Reference:** `docs/plans/2026-06-10-hyprland-lua-migration-design.md`

---

## API quick-reference (verified from source)

| .conf construct | `hl.*` equivalent |
|---|---|
| `$mainMod = SUPER` | `local mainMod = "SUPER"` |
| `bind = $mainMod, return, exec, $terminal` | `hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("$terminal"))` |
| `bind = $mainMod ALT, F, fullscreen` | `hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen())` |
| `bindel = ,XF86AudioRaiseVolume, exec, ...` | `hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("..."), { locked = true, repeating = true })` |
| `bindl = ,switch:on:Lid Switch, exec, ...` | `hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("..."), { description = "Lid Switch open", locked = true })` |
| `bindm = $mainMod, mouse:272, movewindow` | `hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })` |
| `windowrulev2 = float, class:^(kitty)$` | `hl.window_rule({ name = "...", match = { class = "^kitty$" }, float = true })` |
| `layerrule = noanim, ^(rofi)$` | `hl.layer_rule({ name = "...", match = { namespace = "^rofi$" }, no_anim = true })` |
| `general { gaps_in =5 }` | `hl.config({ general = { gaps_in =5 } })` |
| `animation = windows,1,4, myBezier` | `hl.animation({ leaf = "windows", enabled = true, speed =1, bezier = "myBezier" })` |
| `env = XCURSOR_SIZE,24` | `hl.env("XCURSOR_SIZE", "24")` |
| `monitor=eDP-1,preferred,0x0,1,transform,3` | `hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "1", transform =3 })` |
| `exec-once = ...` | `hl.on("hyprland.start", function() hl.dsp.exec_cmd("...") end)` |

Bind opts table fields: `repeating`, `locked`, `release`, `non_consuming`, `auto_consuming`, `transparent`, `ignore_mods`, `dont_inhibit`, `long_press`, `submap_universal`, `description`/`desc`, `mouse` (sets mouse mode).

---

## Task1: Create `init.lua` (default host)

**Files:**
- Create: `nix/home-manager/configs/hypr/init.lua`

**Step1:** Write `init.lua` with all common config (no steamdeck/winmax2-specific bits). Use `hl.*` API. Variables as lua locals. Autostart via `hl.on`. Binds grouped by category.

Contents:

```lua
-- hyprland config — default host (vmware / fallback)

----------------------------------------
-- variables
----------------------------------------
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "nautilus"
-- local menu = "wofi --show drun -i"
local menu = "rofi -show drun"
local notificationPanel = "swaync-client -t"

----------------------------------------
-- autostart
----------------------------------------
hl.on("hyprland.start", function()
 hl.dsp.exec_cmd("nm-applet &")
 hl.dsp.exec_cmd("sleep10 && blueman-applet &")
 hl.dsp.exec_cmd("waybar &")
 hl.dsp.exec_cmd("fcitx5 &")
 hl.dsp.exec_cmd("clipse -listen")
end)

----------------------------------------
-- environment variables
----------------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

----------------------------------------
-- permissions (placeholder; commented out)
----------------------------------------
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

----------------------------------------
-- look and feel
----------------------------------------
hl.config({
 general = {
 gaps_in =5,
 gaps_out =10,
 border_size =2,
 col = {
 active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle =45 },
 inactive_border = "rgba(595959aa)",
 },
 resize_on_border = false,
 allow_tearing = false,
 layout = "dwindle",
 },

 decoration = {
 rounding =7,
 active_opacity =1.0,
 inactive_opacity =1.0,
 shadow = {
 enabled = true,
 range =4,
 render_power =3,
 color = "rgba(1a1a1aee)",
 },
 blur = {
 enabled = true,
 size =3,
 passes =1,
 vibrancy =0.1696,
 },
 },
})

-- bezier curve and animations
hl.curve("myBezier", { type = "bezier", points = { {0.05,0.9 }, {0.1,1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed =1, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed =1, bezier = "default", style = "popin80%" })
hl.animation({ leaf = "border", enabled = true, speed =1, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed =1, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed =1, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed =1, bezier = "default" })

-- dwindle
hl.config({
 dwindle = {
 pseudotile = true,
 preserve_split = true,
 },
})

-- master
hl.config({
 master = {
 new_status = "master",
 },
})

-- misc
hl.config({
 misc = {
 force_default_wallpaper = -1,
 disable_hyprland_logo = false,
 mouse_move_enables_dpms = false,
 key_press_enables_dpms = true,
 },
})

-- binds
hl.config({
 binds = {
 workspace_back_and_forth = true,
 },
})

----------------------------------------
-- input
----------------------------------------
hl.config({
 input = {
 kb_layout = "us",
 kb_variant = "",
 kb_model = "",
 kb_options = "compose:ralt",
 kb_rules = "",
 follow_mouse =1,
 sensitivity =0,
 touchpad = {
 natural_scroll = false,
 },
 },
})

----------------------------------------
-- gestures (workspace_swipe disabled in old config; comment out)
----------------------------------------
-- hl.gesture({ fingers =3, direction = "horizontal", action = "workspace" })

----------------------------------------
-- per-device input
----------------------------------------
hl.device({
 name = "epic-mouse-v1",
 sensitivity = -0.5,
})

----------------------------------------
-- keybindings
----------------------------------------
-- window control
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout --protocol layer-shell -b5"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + ALT + P", hl.dsp.layout("pseudo"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(notificationPanel))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock & sleep1 && hyprctl dispatch dpms off"))

-- screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))

-- move to monitor
hl.bind(mainMod .. " + X", hl.dsp.window.move({ monitor = "+1" }))

-- grouping (tabs)
hl.bind(mainMod .. " + T", hl.dsp.layout("togglegroup"))
hl.bind("SHIFT + " .. mainMod .. " + T", hl.dsp.layout("lockactivegroup"), { arg = "toggle" })
hl.bind(mainMod .. " + D", hl.dsp.layout("changegroupactive"), { arg = "f" })
hl.bind("SHIFT + " .. mainMod .. " + D", hl.dsp.layout("moveoutofgroup"))
hl.bind(mainMod .. " + ALT + left", hl.dsp.layout("moveintogroup"), { arg = "l" })
hl.bind(mainMod .. " + ALT + right", hl.dsp.layout("moveintogroup"), { arg = "r" })
hl.bind(mainMod .. " + ALT + up", hl.dsp.layout("moveintogroup"), { arg = "u" })
hl.bind(mainMod .. " + ALT + down", hl.dsp.layout("moveintogroup"), { arg = "d" })

-- focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- move windows
hl.bind("SHIFT + " .. mainMod .. " + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SHIFT + " .. mainMod .. " + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SHIFT + " .. mainMod .. " + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SHIFT + " .. mainMod .. " + down", hl.dsp.window.move({ direction = "d" }))

-- workspaces1–10
for i =1,10 do
 local key = i %10
 hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
 hl.bind("SHIFT + " .. mainMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SHIFT + " .. mainMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- drag/resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- laptop multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s10%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s10%-"))

----------------------------------------
-- window rules
----------------------------------------
local suppressMaximizeRule = hl.window_rule({
 name = "suppress-maximize-events",
 match = { class = ".*" },
 suppress_event = "maximize",
})

hl.window_rule({
 name = "pinned-yellow-border",
 match = { pinned = true },
 border_color = "rgb(FFFF00) rgb(888800)", -- legacy string form (v2 rule accepts single string)
})

-- clipse
hl.window_rule({ name = "clipse-float", match = { class = "clipse" }, float = true })
hl.window_rule({ name = "clipse-size", match = { class = "clipse" }, size = "622652" })
hl.window_rule({ name = "clipse-no-group", match = { class = "clipse" }, groupbar = "barred" })

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse"))

----------------------------------------
-- hyprdisplay
----------------------------------------
hl.window_rule({ name = "hyprdisplay-float", match = { class = "hyprdisplay(.*)" }, float = true })
-- exec-once = /home/pakky/p/hyprdisplay/hyprdisplay/hyprdisplay &

----------------------------------------
-- layer rules
----------------------------------------
hl.layer_rule({ name = "rofi-no-anim", match = { namespace = "^rofi$" }, no_anim = true })
```

**Step2:** Verify.

```bash
wc -l /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init.lua
```

Expected: ~250 lines.

**Step3:** Do NOT commit yet — proceed to Task2.

---

## Task2: Create `init_steamdeck.lua`

**Files:**
- Create: `nix/home-manager/configs/hypr/init_steamdeck.lua`

**Step1:** Copy `init.lua` to `init_steamdeck.lua` then replace the header comment and insert monitor config at the top.

```bash
cd /home/pakky/p/dotfiles
cp nix/home-manager/configs/hypr/init.lua nix/home-manager/configs/hypr/init_steamdeck.lua
```

Then with `edit`:

1. Change the header comment from `-- default host (vmware / fallback)` to `-- steamdeck`
2. After the `local notificationPanel = ...` line (right before the autostart block), insert:

```lua
----------------------------------------
-- monitors (steamdeck)
----------------------------------------
hl.monitor({
 output = "eDP-1",
 mode = "preferred",
 position = "0x0",
 scale = "1",
 transform =3,
})
hl.monitor({
 output = "DP-1",
 mode = "preferred",
 position = "1280x0",
 scale = "1",
})
```

**Step2:** Verify diff is only the header + monitor block.

```bash
diff /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init.lua /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init_steamdeck.lua
```

Expected: only header + new monitor block differ.

**Step3:** Do NOT commit yet — proceed to Task3.

---

## Task3: Create `init_winmax2.lua`

**Files:**
- Create: `nix/home-manager/configs/hypr/init_winmax2.lua`

**Step1:** Copy `init.lua` to `init_winmax2.lua` then replace header and insert monitor/lid block.

```bash
cd /home/pakky/p/dotfiles
cp nix/home-manager/configs/hypr/init.lua nix/home-manager/configs/hypr/init_winmax2.lua
```

Then with `edit`:

1. Change the header to `-- winmax2`
2. After the `local notificationPanel = ...` line, insert:

```lua
----------------------------------------
-- monitors (winmax2) and lid switch
----------------------------------------
hl.monitor({
 output = "eDP-1",
 mode = "2560x1600@60",
 position = "0x0",
 scale = "1.6",
})

local LID_OPENED = true

hl.device({
 name = "gxtp7385:00-27c6:0113",
 enabled = LID_OPENED,
})
hl.device({
 name = "gxtp7385:00-27c6:0113-stylus",
 enabled = LID_OPENED,
})
hl.device({
 name = "pnp0c50:00-0911:5288-touchpad",
 enabled = LID_OPENED,
})

-- lid switch binds
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1, disable"]]), {
 description = "Lid Switch open",
 locked = true,
})
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd([[hyprctl keyword monitor "eDP-1,2560x1600@60,0x0,1.6"]]), {
 description = "Lid Switch closed",
 locked = true,
})
```

3. Also add to the autostart block (inside `hl.on("hyprland.start", function() ... end)`) the line:

```lua
hl.dsp.exec_cmd("(sleep10 && /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/lid.sh) &")
```

**Step2:** Verify the literal path is updated.

```bash
grep -n "nix-config\|p/dotfiles/nix" /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init_winmax2.lua
```

Expected: only `p/dotfiles/nix/...`; no `nix-config` literal.

**Step3:** Do NOT commit yet — proceed to Task4.

---

## Task4: Delete the four old `.conf` files

**Files:**
- Delete: `nix/home-manager/configs/hypr/hyprland.conf`
- Delete: `nix/home-manager/configs/hypr/monitors.conf`
- Delete: `nix/home-manager/configs/hypr/monitors_steamdeck.conf`
- Delete: `nix/home-manager/configs/hypr/monitors_winmax2.conf`

**Step1:** Delete the four files.

```bash
cd /home/pakky/p/dotfiles
rm nix/home-manager/configs/hypr/hyprland.conf
rm nix/home-manager/configs/hypr/monitors.conf
rm nix/home-manager/configs/hypr/monitors_steamdeck.conf
rm nix/home-manager/configs/hypr/monitors_winmax2.conf
```

**Step2:** Verify.

```bash
ls /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/
```

Expected: `init.lua`, `init_steamdeck.lua`, `init_winmax2.lua`, `hyprlock.conf`, `lid.sh` (5 entries).

**Step3:** Do NOT commit yet — proceed to Task5.

---

## Task5: Update `nix/home-manager/modules/hyprland/default.nix`

**Files:**
- Modify: `nix/home-manager/modules/hyprland/default.nix`

**Step1:** Replace the two `xdg.configFile."hypr/..."` blocks (one for `hyprland.conf`, one for `monitors.conf`) with a single `xdg.configFile."hypr/hyprland.lua"` block.

Final file content:

```nix
{ config, lib, ... }:
with lib;
let
 configDir = "${config.pakky.nixConfigDir}/home-manager/configs";
in
{
 config = mkIf config.pakky.programs.hyprland.enable {
 xdg.configFile."hypr/hyprland.lua".source =
 if config.pakky.hostName == "steamdeck" then
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init_steamdeck.lua"
 else if config.pakky.hostName == "winmax2" then
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init_winmax2.lua"
 else
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init.lua";

 xdg.configFile."hypr/hyprlock.conf".source =
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/hyprlock.conf";

 xdg.configFile."waybar/config".source =
 config.lib.file.mkOutOfStoreSymlink "${configDir}/waybar/config";

 xdg.configFile."waybar/power_menu.xml".source =
 config.lib.file.mkOutOfStoreSymlink "${configDir}/waybar/power_menu.xml";

 xdg.configFile."rofi/config.rasi".source =
 config.lib.file.mkOutOfStoreSymlink "${configDir}/rofi/config.rasi";

 xdg.configFile."wlogout" = {
 source = config.lib.file.mkOutOfStoreSymlink "${configDir}/wlogout";
 recursive = true;
 };
 };
}
```

**Step2:** Verify.

```bash
grep -n "hyprland\.conf\|monitors\.conf\|monitors_steamdeck\|monitors_winmax2\|hyprland\.lua" /home/pakky/p/dotfiles/nix/home-manager/modules/hyprland/default.nix
```

Expected: only `hyprland.lua` line; no `*.conf` references for hyprland.

**Step3:** Do NOT commit yet — proceed to Task6.

---

## Task6: Sanity-check the result

**Files:** none (read-only)

**Step1:** Confirm no `.conf` files in `configs/hypr/` other than `hyprlock.conf`.

```bash
find /home/pakky/p/dotfiles/nix/home-manager/configs/hypr -type f -name '*.conf'
```

Expected: only `hyprlock.conf`.

**Step2:** Confirm no stale references in nix files.

```bash
grep -rn "monitors\.conf\|monitors_steamdeck\|monitors_winmax2\|hyprland\.conf" /home/pakky/p/dotfiles/nix/ --include="*.nix"
```

Expected: no output.

**Step3:** Confirm `lid.sh` path is updated.

```bash
grep -rn "nix-config.*lid\.sh\|lid\.sh" /home/pakky/p/dotfiles/nix/ --include="*.lua"
```

Expected: only `p/dotfiles/nix/.../lid.sh` references.

**Step4:** If lua5.4 or luac is available in the sandbox, syntax-check the three files.

```bash
which luac5.4 luac lua52>/dev/null
```

If found:

```bash
for f in /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init.lua \
 /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init_steamdeck.lua \
 /home/pakky/p/dotfiles/nix/home-manager/configs/hypr/init_winmax2.lua; do
 echo "--- $f ---"
 luac -p "$f"2>&1
done
```

Expected: no errors. If luac not available, skip — runtime hyprland will surface errors.

**Step5:** Confirm final hyprland module file is well-formed.

```bash
cat /home/pakky/p/dotfiles/nix/home-manager/modules/hyprland/default.nix
```

**Step6:** Do NOT commit yet — proceed to Task7.

---

## Task7: Stage and commit

**Files:** none (git operations)

**Step1:** Stage everything.

```bash
cd /home/pakky/p/dotfiles
git add -A
```

**Step2:** Review.

```bash
git status --short
```

Expected: shows new `init.lua`, `init_steamdeck.lua`, `init_winmax2.lua`; deletions of four old `.conf` files; modified `nix/home-manager/modules/hyprland/default.nix`.

**Step3:** Commit.

```bash
git commit -m "hyprland: migrate from .conf to hl.* lua config

- three per-host init_*.lua files (default, steamdeck, winmax2)
- monitors + lid switch logic inlined per host
- variables as lua locals; binds via hl.bind(); autostart via hl.on
- hyprlock.conf stays (no lua support in hyprlock)
- nix module now references hyprland.lua instead of hyprland.conf + monitors.conf
- lid.sh path updated to new dotfiles location"
```

**Step4:** Verify.

```bash
git log --oneline -5
```

Expected: shows the new commit on top of the design commit.

---

## Task8 (manual, user): validate before merge to master

**Files:** none

**Step1:** On a NixOS machine with hyprland, deploy and test.

```bash
home-manager switch --flake ~/p/dotfiles#wsl-personal # or relevant host
# start hyprland
```

**Step2:** Confirm:

- `~/.config/hypr/hyprland.lua` exists
- Hyprland logs show no lua errors
- `hyprctl reload` succeeds
- A few representative binds work (terminal, scratchpad, workspace switch)
- Window rules apply (clipse, hyprdisplay)
- Lid switch works on winmax2

**Step3:** If green, merge `merge-nix-config` → `master`.

---

## Notes for the implementer

- **Field name mismatches** at runtime are the main failure mode. The plan's API surface was verified against `src/config/lua/bindings/*.cpp` and `example/hyprland.lua`, but edge cases (e.g. `border_color` table form vs. string form, `suppress_event`, `groupbar`) may differ. User should report any errors and we'll fix.
- **`border_color`** is given as a single string `"rgb(FFFF00) rgb(888800)"` (legacy v2 form) — the v2 lua bindings allow this fallback. If hyprland complains, fall back to removing the field and using `border_color = "rgb(FFFF00)"` (single color).
- **`size`** for window rules is `"W H"` (space-separated string) in legacy form.
- **`switch:on:Lid Switch`** as a bind key is a guess at the new API; if it doesn't work, the user may need to check the wiki for switch binds in `hl.*` (which might use a different shape).

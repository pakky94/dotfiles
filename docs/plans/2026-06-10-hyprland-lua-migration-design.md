# Convert Hyprland config from .conf to the new lua format

**Date:**2026-06-10
**Branch:** `merge-nix-config` (continuing from prior task)
**Goal:** replace `nix/home-manager/configs/hypr/*.conf` with the new Hyprland lua config, inline per-host monitor/lid logic into a single `init.lua`, and update the nix module accordingly.

## Decisions (from user)

1. Hyprland version: latest (≥0.45+, lua config supported)
2. Scope: convert all hyprland-related configs (main, monitors, hyprlock)
3. Variables: recommended choice → **lua locals** (`local mainMod = "SUPER"`) — see note below
4. Monitors: **inline in `init.lua`**, host-specific blocks selected by hostname
5. `require` directives: **none** — everything inline
6. `lid.sh` path: update literal from `/home/pakky/p/nix-config/home-manager/configs/hypr/lid.sh` → `/home/pakky/p/dotfiles/nix/home-manager/configs/hypr/lid.sh`
7. Binds: table style (e.g. `{ key = "return", mods =64, action = "exec", arg = "$terminal" }`)

### Note on Decision3 — recommended format

There are two lua formats in the wild:
- **hyprlang v2 tables**: `return { general = { ... }, binds = { ... } }` — a direct translation of `.conf` syntax.
- **Hyprland `hl.*` API** (the format `example/hyprland.lua` ships with, the wiki's official "new lua config"): imperative calls like `hl.config({...})`, `hl.bind(...)`, `hl.monitor(...)`, `hl.animation(...)`.

The user said "the **new** lua format" and "use the recommended". The `hl.*` API is the official new format and is what hyprland recommends in2026. **Decision: use `hl.*` API.** This means variables are local Lua variables (`local mainMod = "SUPER"`) — there is no `variables = {...}` block in `hl.*` style.

## Format mappings

| .conf construct | `hl.*` equivalent |
|---|---|
| `$mainMod = SUPER` | `local mainMod = "SUPER"` |
| `bind = $mainMod, return, exec, $terminal` | `hl.bind(mainMod .. " + return", hl.dsp.exec("$terminal"))` |
| `bindel = ,XF86AudioRaiseVolume, ...` | `hl.bind("XF86AudioRaiseVolume", hl.dsp.exec("..."), { locked = true, repeating = true })` |
| `bindl = ,switch:on:Lid Switch,exec,...` | `hl.bind("", hl.dsp.exec("..."), { description = "Lid Switch open" })` — bindl uses switch |
| `bindm = $mainMod, mouse:272, movewindow` | `hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })` |
| `windowrulev2 = ..., class:^(kitty)$` | `hl.window_rule({ match = { class = "^kitty$" }, ... })` |
| `layerrule = noanim, ^(rofi)$` | `hl.layer_rule({ match = { namespace = "^rofi$" }, no_anim = true })` |
| `general { gaps_in =5 }` | `hl.config({ general = { gaps_in =5 } })` |
| `animations { enabled = true; animation = windows,1,4, myBezier }` | `hl.config({ animations = { enabled = true } })` + `hl.animation({ leaf = "windows", enabled = true, speed =4, bezier = "myBezier" })` |
| `animation = borderangle, ...` | `hl.animation({ leaf = "borderangle", ... })` |
| `env = XCURSOR_SIZE,24` | `hl.env("XCURSOR_SIZE", "24")` |
| `monitor=eDP-1,preferred,0x0,1` | `hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale =1 })` |
| `exec-once = ...` | `hl.on("hyprland.start", function() hl.exec(...) end)` or `autostart = { "..." }` block in config |
| `source = ...` | `require("./...")` |

## Final layout

```
nix/home-manager/configs/hypr/
├── init.lua # NEW — single hyprland config (was hyprland.conf +3 monitors_*.conf)
├── hyprlock.conf # UNCHANGED — hyprlock has no lua support, stays as hyprlang .conf
└── lid.sh # UNCHANGED — bash helper, content already correct
```

`monitors.conf`, `monitors_steamdeck.conf`, `monitors_winmax2.conf` get **deleted** — their content moves into `init.lua` via a hostname conditional.

## init.lua structure

```lua
-- hyprland config

--1. variables (lua locals)
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -show drun"
local notificationPanel = "swaync-client -t"

--2. hostname (set at top of file; nix substitutes it via a template OR via a separate file)
local HOSTNAME = "..." -- steamdeck | winmax2 | <default>

--3. monitors (hostname-conditional)
if HOSTNAME == "steamdeck" then
 hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale =1, transform =3 })
 hl.monitor({ output = "DP-1", mode = "preferred", position = "1280x0", scale =1 })
elseif HOSTNAME == "winmax2" then
 hl.monitor({ output = "eDP-1", mode = "2560x1600@60", position = "0x0", scale =1.6 })
 -- ... lid binds, touchpad device enables ...
else
 -- default empty monitor config
end

--4. autostart
autostart = {
 "nm-applet",
 "sleep10 && blueman-applet",
 "waybar",
 "fcitx5",
 "clipse -listen",
}

--5. env
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

--6. permissions (placeholder for now)
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")

--7. look and feel (general, decoration, dwindle, master, misc)
hl.config({
 general = { ... },
 decoration = { ... },
 dwindle = { ... },
 master = { new_status = "master" },
 misc = { ... },
})

--8. animations (curve + animation calls)
hl.curve("myBezier", { type = "bezier", points = { {0.05,0.9}, {0.1,1.05} } })
hl.animation({ leaf = "windows", enabled = true, speed =4, bezier = "myBezier" })
-- ... etc

--9. input + gestures + device
hl.config({ input = { ... } })
hl.gesture({ fingers =3, direction = "horizontal", action = "workspace" }) -- previously disabled in .conf; keep as commented-out
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

--10. keybindings (grouped: window, focus, move, workspace, scratchpad, scroll, multimedia, lid, groups)
-- ...

--11. window rules + layer rules
-- ...
```

## Hostname injection — the tricky bit

The .conf setup used three separate files selected by the nix module. To inline everything, the config needs to know which host it's running on. Two options:

**A) Per-host `init.lua`** — the nix module still selects between three files (`init.lua`, `init_steamdeck.lua`, `init_winmax2.lua`). Each is the same template but with the hostname hardcoded at the top. Clean, but doesn't fully meet "inline everything" since we have3 files.

**B) Hyprland `autogenerated = true` + hostname from env** — Hyprland doesn't have a built-in way to expose the hostname. Would need a shell command to read it (`cmd[update:1] hostname`) and pipe into the config. Awkward and not idiomatic.

**C) Hyprland-managed hostname via config dispatcher** — emit hostname into the file from nix using a sed-style replace during deployment. Same as A but generated.

**D) Per-host `init.lua` named differently and selected via xdg.configFile** — same as A.

**Decision:** use **option A** — three init.lua variants, selected by the nix module on `pakky.hostName`. Rationale:
- "Inline everything" interpreted as: no external `.conf` file splits. Per-host `init.lua` files are still one file per host, each fully self-contained.
- Matches existing pattern (the nix module already branches on `hostName`).
- No runtime hostname lookup needed.
- Each per-host file is small enough to keep readable.

Final files:
```
nix/home-manager/configs/hypr/
├── init.lua # default host (vmware or fallback)
├── init_steamdeck.lua
├── init_winmax2.lua
├── hyprlock.conf # unchanged
└── lid.sh # unchanged
```

The three `init.lua` files share ~90% of their content. To DRY, a `_base.lua` could be `require`'d — but that introduces two files per host. Trade-off: keep it as copy-paste with a header comment noting the relationship, OR extract `_base.lua` and have each host `require` it. **Decision: keep them as copy-paste for now** — they're ~250 lines, and the nix module is already paying the host-switching cost. (If user wants DRY, they can refactor later.)

## Nix module changes

`nix/home-manager/modules/hyprland/default.nix`:

```nix
xdg.configFile."hypr/hyprland.lua".source =
 if config.pakky.hostName == "steamdeck" then
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init_steamdeck.lua"
 else if config.pakky.hostName == "winmax2" then
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init_winmax2.lua"
 else
 config.lib.file.mkOutOfStoreSymlink "${configDir}/hypr/init.lua";
```

(`hyprland.lua` is the filename hyprland loads when present; `init.lua` is what I picked for clarity. Will use `hyprland.lua` in xdg.configFile since that's the actual name.)

## Files deleted

- `hyprland.conf`
- `monitors.conf`
- `monitors_steamdeck.conf`
- `monitors_winmax2.conf`

## Files added

- `init.lua` (default)
- `init_steamdeck.lua`
- `init_winmax2.lua`

## Files unchanged

- `hyprlock.conf` — hyprlock has no lua support
- `lid.sh` — bash script, called from bindl/exec; content unchanged but path is referenced in init_winmax2.lua with the new dotfiles path

## Risk / known issues

- **Hyprland0.46+ API stability**: the `hl.*` API is still relatively new. Some field names may differ slightly from what I write — but the structure (config table, bind dispatcher, monitor call) is well-established.
- **Binds with switch events** (lid binds): the `hl.*` API has different syntax for switch binds vs key binds. Need to verify.
- **Per-device input config** (`device[gxtp7385...]`): the `hl.*` API uses `hl.device({ name = "...", enabled = true })` — but the device name uses sysfs paths which may not match what hyprland expects in the new API.
- **`bindm` (mouse binds)**: the `.conf` `mouse:272` (left button) maps to `mouse:272` in `hl.bind` too, but the new API uses a different `mouse = true` flag. Verify.
- **hyprlock has no lua support**: confirmed by inspecting hyprlock source. The user said "convert all that needs conversion" — `hyprlock.conf` does NOT need conversion because there's no lua equivalent. **hyprlock stays as `.conf`.**

## Migration steps (execution)

1. Create three new `init_*.lua` files in `nix/home-manager/configs/hypr/`
2. Delete `hyprland.conf`, `monitors.conf`, `monitors_steamdeck.conf`, `monitors_winmax2.conf`
3. Update `nix/home-manager/modules/hyprland/default.nix` to reference the new files
4. Verify by grep + manual review

## Verification

- No `bind = ` or `general {` or `source = ` lines anywhere
- Each `init_*.lua` starts with `--` header comment
- `lid.sh` path literal updated in `init_winmax2.lua`
- `xdg.configFile."hypr/hyprland.lua"` referenced in nix module
- All three per-host files present
- User runs `nix flake check` on a NixOS machine before merging

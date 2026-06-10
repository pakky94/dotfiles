-- hyprland config — winmax2

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

----------------------------------------
-- autostart
----------------------------------------
hl.on("hyprland.start", function()
 hl.dsp.exec_cmd("nm-applet &")
 hl.dsp.exec_cmd("sleep10 && blueman-applet &")
 hl.dsp.exec_cmd("waybar &")
 hl.dsp.exec_cmd("fcitx5 &")
 hl.dsp.exec_cmd("clipse -listen")
 hl.dsp.exec_cmd("(sleep10 && /home/pakky/.local/share/chezmoi/nix/home-manager/configs/hypr/lid.sh) &")
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
-- gestures (workspace_swipe disabled in old config; commented out)
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

-- workspaces1-10
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
 border_color = "rgb(FFFF00) rgb(888800)",
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

local wezterm = require 'wezterm'

local config = wezterm.config_builder()
-- config.color_scheme = 'Solarized Dark Higher Contrast'
config.color_scheme = 'Night Owl (Gogh)'
config.font = wezterm.font('CaskaydiaCove NF')
config.initial_cols = 150
config.initial_rows = 40

local launch_menu = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }

  table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'pwsh.exe', '-NoLogo' },
  })
end

config.launch_menu = launch_menu

return config

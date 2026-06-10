vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.hlsearch = false

vim.wo.number = true
vim.wo.relativenumber = true

vim.o.scrolloff = 5
vim.o.mouse = 'a'

vim.o.breakindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = 'yes'

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.o.fixeol = false

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Always use clipboard
-- vim.o.clipboard = 'unnamedplus'

-- WSL copy/paste from clipboard
--if (vim.fn.has('wsl') == 1) then
--  vim.cmd [[let g:clipboard = {
--  \   'name': 'WslClipboard',
--  \   'copy': {
--  \      '+': 'clip.exe',
--  \      '*': 'clip.exe',
--  \    },
--  \   'paste': {
--  \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
--  \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
--  \   },
--  \   'cache_enabled': 0,
--  \ }]]
--end

-- OSC 52 not yet working in alacritty / wezterm
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

--[[
-- Use OSC 52 only for yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
    local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
    copy_to_unnamed(vim.v.event.regcontents)
  end
})
--]]

-- Keymaps for better default experience
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', 'U', ':redo<cr>')

vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste (better)' })

-- Window management
vim.keymap.set('n', '<C-right>', '<C-w>l')
vim.keymap.set('n', '<C-down>', '<C-w>j')
vim.keymap.set('n', '<C-left>', '<C-w>h')
vim.keymap.set('n', '<C-up>', '<C-w>k')

vim.keymap.set('n', '<M-right>', '<C-w>>')
vim.keymap.set('n', '<M-down>', '<C-w>-')
vim.keymap.set('n', '<M-left>', '<C-w><')
vim.keymap.set('n', '<M-up>', '<C-w>+')

-- document existing key chains
local wk = require('which-key')
wk.add({
  { '<leader>c',  group = '[C]ode' },
  { '<leader>d',  group = '[D]ebug' },
  { '<leader>f',  group = '[F]iles' },
  { '<leader>g',  group = '[G]it' },
  { '<leader>gw', group = '[W]orktree' },
  { '<leader>h',  group = 'Git [H]unk' },
  { '<leader>r',  group = '[R]ename' },
  { '<leader>s',  group = '[S]earch' },
  { '<leader>t',  group = '[T]oggle' },
  { '<leader>w',  group = '[W]orkspace' },
})

-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
wk.add({
  { '<leader>',  group = 'VISUAL <leader>' },
  { '<leader>h', group = 'Git [H]unk' },
}, { mode = 'v' })

return {
  'pakky94/nvim-window',
  config = function ()
    local nw = require'nvim-window'
    nw.setup({
      chars = {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
        'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
      },
      normal_hl = 'Normal',
      hint_hl = 'Bold',
      border = 'single',
      quick_select = true,
    })

    vim.keymap.set('n', '<C-w>w', nw.pick, { desc = '[P]ick window' })
    vim.keymap.set('n', '<C-w><C-w>', nw.pick, { desc = '[P]ick window' })
  end
}

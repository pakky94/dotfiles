return {
  'ggandor/lightspeed.nvim',
  dependencies = {
    'tpope/vim-repeat',
  },
  opts = {},
  config = function(_, opts)
    require 'lightspeed'.setup(opts)
    vim.keymap.set('n', 's', '<Plug>Lightspeed_omni_s')
  end,
}

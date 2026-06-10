return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require("telescope").load_extension('harpoon')

    vim.keymap.set('n', '<leader>wh', require('harpoon.mark').add_file, { desc = '[H]arpoon add' })
    vim.keymap.set('n', '<leader>wH', require('harpoon.ui').toggle_quick_menu, { desc = '[H]arpoon window' })

    vim.keymap.set('n', '<A-1>', ':lua require("harpoon.ui").nav_file(1)<CR>')
    vim.keymap.set('n', '<A-2>', ':lua require("harpoon.ui").nav_file(2)<CR>')
    vim.keymap.set('n', '<A-3>', ':lua require("harpoon.ui").nav_file(3)<CR>')
    vim.keymap.set('n', '<A-4>', ':lua require("harpoon.ui").nav_file(4)<CR>')
    vim.keymap.set('n', '<A-5>', ':lua require("harpoon.ui").nav_file(5)<CR>')
    vim.keymap.set('n', '<A-6>', ':lua require("harpoon.ui").nav_file(6)<CR>')
  end
}

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require('todo-comments').setup({})
    vim.keymap.set('n', '<leader>std', ":TodoTelescope<cr>", { desc = '[S]earch [td] TODOs' })
  end
}

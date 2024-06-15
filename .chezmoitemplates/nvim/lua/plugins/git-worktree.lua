return {
  'ThePrimeagen/git-worktree.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require("telescope").load_extension('git_worktree')

    vim.keymap.set('n', '<leader>gwl', require('telescope').extensions.git_worktree.git_worktrees,
      { desc = '[L]ist worktrees' })
    vim.keymap.set('n', '<leader>gwc', require('telescope').extensions.git_worktree.create_git_worktree,
      { desc = '[L]ist worktrees' })
  end
}

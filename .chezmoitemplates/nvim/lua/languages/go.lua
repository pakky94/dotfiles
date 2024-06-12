vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    -- require("./spacing/four")
    vim.keymap.set('n', '<leader>dt', require 'dap-go'.debug_test, { desc = '[T]est (debug)' })
  end
})

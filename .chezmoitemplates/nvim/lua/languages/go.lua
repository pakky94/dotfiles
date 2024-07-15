vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    -- require("./spacing/four")
    vim.keymap.set('n', '<leader>dt', require 'dap-go'.debug_test, { desc = '[T]est (debug)' })

    local port = os.getenv("DELVE_HEADLESS_PORT")

    if (port == nil or port == "") then
      port = "38697"
    end

    require('dap-go').setup({
      dap_configurations = {
        {
          type = "go",
          name = "Attach remote",
          mode = "remote",
          request = "attach",
        },
      },
      delve = {
        port = port
      },
    })
  end
})

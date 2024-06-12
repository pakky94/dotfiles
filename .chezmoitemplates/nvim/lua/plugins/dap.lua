return {
  'mfussenegger/nvim-dap',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      dependencies = {
        'nvim-neotest/nvim-nio'
      }
    },
    'theHamsta/nvim-dap-virtual-text',
    {
      "williamboman/mason.nvim",
      opts = { ensure_installed = { "delve" } },
    },
    {
      "leoluz/nvim-dap-go",
      config = true,
    }
  },
  config = function()
    require('telescope').load_extension('dap')
    vim.keymap.set('n', '<F5>', require 'dap'.continue)
    vim.keymap.set('n', '<F1>', require 'dap'.step_into)
    vim.keymap.set('n', '<F2>', require 'dap'.step_over)
    vim.keymap.set('n', '<F3>', require 'dap'.step_out)
    vim.keymap.set('n', '<leader>db', require 'dap'.toggle_breakpoint, { desc = '[B]reakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
      require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = '[B]reakpoint conditional' })
    vim.keymap.set('n', '<leader>dr', require 'dap'.repl.open, { desc = '[R]epl' })
    vim.keymap.set('n', '<leader>du', require 'dapui'.toggle, { desc = '[U]i (toggle)' })

    require('dapui').setup()
    require('nvim-dap-virtual-text').setup()

    -- Start dapui when debugging
    local dap, dapui = require('dap'), require('dapui')
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end
}

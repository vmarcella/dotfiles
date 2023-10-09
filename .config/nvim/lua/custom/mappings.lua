local M = {}

M.crates = {
  n = {
    ["<leader>rcu"] = {
      function()
        require('crates').upgrade_all_crates()
      end,
      "Update all crates"
    }
  }
}

-- Debugging adapter protocol mappings
M.dap = {
  plugin = true,
  n = {
    ["<leader>dc"] = {
      function()
        require('dap').continue()
      end,
      "Continue"
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Repl"
    },
    ["<leader>db"] = {
      function()
        require('dap').toggle_breakpoint()
      end,
      "Toggle Breakpoint"
    },
    ["<leader>dus"] = {
      function ()
        local widgets = require('dap.ui.widgets')
        local sidebar = widgets.sidebar(widgets.scopes)
        sidebar.open()
      end,
      "Open Debugging sidebar"
    }
  }
}

M.dap_go = {
  plugin = true,
  n = {
    ["<leader>dgt"] = {
      function()
        require('dap-go').debug_test()
      end,
      "Debug go test"
    },
    ["<leader>dgl"] = {
      function()
        require('dap-go').debug_last()
      end,
      "Debug last go test"
    }
  }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end,
      "Debug python test method"
    }
  }
}

return M

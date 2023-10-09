local plugins = {
  {
    -- AI code completion.
    "github/copilot.vim",
    lazy=false,
  },
  -- Dependencies, syntax highlighting, and LSPs
  {
    -- Installs lsp, diagnostic, and other dev tools needed by other plugins.
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Golang
        "gopls",

        -- Python
        "black",
        "debugpy",
        "pyright",
        "mypy",
        "ruff",
      }
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "json",
        "yaml",
        "toml",
        "zig",
        "c",
        "cpp",
        "rust",
        "go",
        "bash",
        "python",
        "markdown"
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    -- Add null-ls for linter support.
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require "custom.configs.null-ls"
      end,
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  -- Debuggers
  {
    -- Debugger adapter protocol client.
    "mfussenegger/nvim-dap",
    config = function()
      require("core.utils").load_mappings("dap")
    end,
  },
  {
    -- DAP UI
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    -- DAP for golang
    "dreamsofcode-io/nvim-dap-go",
    ft = "go",
    dependencies = {"mfussenegger/nvim-dap"},
    config = function(_, opts)
      require("dap-go").setup(opts)
      require("core.utils").load_mappings("dap_go")
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui"
    },
    config = function(_, opts)
      local file = io.popen("which python3")
      local path = file:read("*l")
      file:close()

      if not path then
        error("python3 executable not found")
      end

      require('dap-python').resolve_python = function()
        return path
      end

      require('dap-python').test_runner = 'pytest'

      require("dap-python").setup(path)
      require("core.utils").load_mappings("dap_python")

    end,
  }
}


return plugins

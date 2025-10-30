local plugins = {
  {
    -- AI code completion.
    "github/copilot.vim",
    lazy = false,
  },
  -- Dependencies, syntax highlighting, and LSPs
  {
    -- Installs lsp, diagnostic, and other dev tools needed by other plugins.
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Github actions
        "actionlint",

        -- bash
        "shfmt",
        "shellharden",
        "bash-language-server",

        -- bicep
        "bicep-lsp",

        -- cmake
        "cmake-language-server",

        -- Docker
        "dockerfile-language-server",
        "docker-compose-language-service",
        "hadolint",

        -- rust
        -- "rust-analyzer",

        -- Golang
        "gopls",
        "gotests",
        "golines",
        "gofumpt",
        "staticcheck",

        -- C#
        "omnisharp",

        -- C++
        "clangd",

        -- Python
        "autoflake",
        "black",
        "debugpy",
        "pyright",
        "mypy",
        "flake8",
        "isort",
        "ruff",
        "ruff-lsp",
        "pyproject-flake8",

        -- typescript
        "typescript-language-server",
        "eslint-lsp",
        "prettier",
        "js-debug-adapter",

        -- markdown
        "marksman",
        "markdownlint",

        -- make
        "checkmake",

        -- java
        "java-language-server",

        -- lua
        "lua-language-server",
        "stylua",
        "selene",

        -- terraform
        "tflint",
        "tfsec",
        "terraform-ls",

        -- trivy (Security scanner)
        "trivy",

        -- json
        "fixjson",
        "json-lsp",

        -- toml
        "taplo",

        -- yaml
        "yamllint",
        "yamlfmt",
        "yamlfix",
        "yaml-language-server",

        -- vim
        "vim-language-server",

        -- zig
        "zls",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "bicep",
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
        "markdown",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    -- Add null-ls for linter support.
    -- (none-ls is the community maintained version)
    dependencies = {
      "nvimtools/none-ls.nvim",
      config = function()
        require "configs.null-ls"
      end,
    },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local M = require "nvchad.configs.cmp"
      table.insert(M.sources, { name = "crates" })
      return M
    end,
  },
  {
    "saecki/crates.nvim",
    dependencies = "hrsh7th/nvim-cmp",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      crates.show()
    end,
  },
  -- Debuggers
  {
    "nvim-neotest/nvim-nio",
  },
  {
    -- Debugger adapter protocol client.
    "mfussenegger/nvim-dap",
    dependencies = "nvim-neotest/nvim-nio",
  },
  {
    -- DAP UI
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
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
    end,
  },
  {
    -- DAP for golang
    "dreamsofcode-io/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function(_, opts)
      require("dap-go").setup(opts)
      --require("core.utils").load_mappings "dap_go"
    end,
  },
  {
    -- DAP for python
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local file = io.popen "which python3"
      local path = file:read "*l"
      file:close()

      if not path then
        error "python3 executable not found"
      end

      require("dap-python").resolve_python = function()
        return path
      end

      require("dap-python").test_runner = "pytest"

      require("dap-python").setup(path)
      --require("core.utils").load_mappings "dap_python"
    end,
  },
}

return plugins

local nvchad_on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capablities
local on_init = require("nvchad.configs.lspconfig").on_init

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

-- LSP servers that don't need any custom configuration should be defined
-- here.
local servers = {
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "vimls",
  "terraformls",
  "tflint",
  "jsonls",
  "marksman",
  "helm_ls",
  "graphql",
  "dockerls",
  "docker_compose_language_service",
  "csharp_ls",
  "zls",
  "ruff",
  "ruff_lsp",
  "taplo",
}

-- List of servers we want to enable/disable formatting for.
local lsp_format_enabled = {
  ["html"] = false,
  ["tsserver"] = false,
  ["eslint"] = false,
  ["cssls"] = false,
  ["ruff"] = true,
  ["ruff_lsp"] = true,
  ["rust_analyzer"] = true,
  ["pyright"] = true,
  ["gopls"] = true,
  ["lua_ls"] = false,
  ["yamlls"] = true,
}

-- Create autogroup for Lsp formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Function to format on save, based on the server
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format {
    bufnr = bufnr,
    filter = function(client)
      return lsp_format_enabled[client.name]
    end,
  }
end

-- Override the on_attach function to enable formatting on save, but only for
-- servers that support it.
local on_attach = function(client, bufnr)
  nvchad_on_attach(client, bufnr)
  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end

-- Add borders back to hover boxes.
local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    handlers = handlers,
  }
end

local bicep_path = vim.fn.stdpath "data" .. "/mason/bin/bicep-lsp"

lspconfig.bicep.setup {
  cmd = { bicep_path },
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  handlers = handlers,
}

-- Manual setup for eslint
lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
  on_init = on_init,
  capabilities = capabilities,
  handlers = handlers,
}

-- Manual setup for gopls
lspconfig.gopls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true, unreachable = true },
    },
  },
  handlers = handlers,
}

-- Manual setup for rust_analyzer
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "rust" },
  root_dir = util.root_pattern "Cargo.toml",
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
      },
      cargo = { allFeatures = true },
    },
  },
  handlers = handlers,
}

-- Manual setup for pyright
lspconfig.pyright.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "python" },
  root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt"),
  handlers = handlers,
}

-- Manual setup for typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  init_options = { preferences = { disableSuggestions = true } },
  settings = { documentFormatting = false },
  handlers = handlers,
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  handlers = handlers,
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = "LuaJIT",
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            },
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          },
        },
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end,
}

lspconfig.yamlls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    yaml = {
      schemas = {
        -- Github Actions
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        --  Azure Container apps
        ["https://json.schemastore.org/azure-containerapp-template.json"] = "/**/*.aca.yaml",
        -- Azure pipelines
        ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = "/.pipelines/*",
      },
    },
  },
  handlers = handlers,
}

local on_attach = require('plugins.configs.lspconfig').on_attach
local capabilities = require('plugins.configs.lspconfig').capablities

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

local servers = {
  "bashls",
  "bicep",
  "cmake",
  "cssls",
  "eslint",
  "vimls",
  "terraformls",
  "yamlls",
  "lua_ls",
  "jsonls",
  "marksman",
  "helm_ls",
  "graphql",
  "dockerls",
  "docker_compose_language_service",
  "csharp_ls",
  "zls"
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities
  }
end

-- Manual setup for gopls
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = { "go", "gomod", "gowork", "gotmpl"},
  root_dir = util.root_pattern("go.work","go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        unreachable = true,
      },
    }
  }
}

-- Manual setup for rust_analyzer
lspconfig.rust_analyzer.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "rust" },
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      }
    }
  }

}

-- Manual setup for pyright
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
}

-- Manual setup for typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    preferences = {
      disableSuggestions = true,
    }
  }
}

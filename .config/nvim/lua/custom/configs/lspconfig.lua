local on_attach = require('plugins.configs.lspconfig').on_attach
local capabilities = require('plugins.configs.lspconfig').capablities

local lspconfig = require "lspconfig"
local servers = {
  "bashls",
  "bicep",
  "cmake",
  "cssls",
  "rust_analyzer",
  "eslint",
  "gopls",
  "pyright",
  "vimls",
  "terraformls",
  "tsserver",
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

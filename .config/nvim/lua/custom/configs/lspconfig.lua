local on_attach = require('plugins.configs.lspconfig').on_attach

local capabilities = require('plugins.configs.lspconfig').capablities

local lspconfig = require "lspconfig"

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capablities = capabilities,
  filetypes = {"rust"}
})

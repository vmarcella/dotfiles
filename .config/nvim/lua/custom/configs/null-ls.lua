local null_ls = require "null-ls"

local completion = null_ls.builtins.completion
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local hover = null_ls.builtins.hover

local sources = {
  completion.spell,
  completion.tags,

  diagnostics.actionlint,
  diagnostics.shellcheck,
  diagnostics.buf,
  diagnostics.checkmake,
  diagnostics.checkstyle,
  diagnostics.clang_check,
  diagnostics.cmake_lint,
  diagnostics.cppcheck,
  diagnostics.cpplint,
  diagnostics.deno_lint,
  diagnostics.dotenv_linter,
  diagnostics.flake8,
  diagnostics.luacheck,
  diagnostics.markdownlint,
  diagnostics.ruff,
  diagnostics.pylint,
  diagnostics.staticcheck,
  diagnostics.tfsec,
  diagnostics.tsc,
  diagnostics.yamllint,
  diagnostics.zsh,


  formatting.autoflake,
  formatting.autopep8,
  formatting.black,
  formatting.buf,
  formatting.cbfmt,
  formatting.clang_format,
  formatting.cmake_format,
  formatting.csharpier,
  formatting.deno_fmt,
  formatting.fixjson,
  formatting.gofmt,
  formatting.goimports,
  formatting.isort,
  formatting.lua_format,
  formatting.markdownlint,
  formatting.ruff,
  formatting.rustfmt,
  formatting.shellharden,
  formatting.shfmt,
  formatting.sqlfluff,
  formatting.sql_formatter,
  formatting.terrafmt,
  formatting.terraform_fmt,
  formatting.textlint,
  formatting.yamlfmt,
  formatting.zigfmt,

  hover.dictionary,
  hover.printenv,
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
                vim.lsp.buf.format({ async = false })
              end,
          })
      end
  end,
}

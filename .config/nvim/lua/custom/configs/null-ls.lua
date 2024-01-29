local null_ls = require "null-ls"
local augroup = vim.api.nvim_create_augroup("LSPFormatting", {})

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
  diagnostics.eslint,
  diagnostics.dotenv_linter,
  diagnostics.flake8,
  diagnostics.mypy,
  diagnostics.pyproject_flake8,
  diagnostics.luacheck,
  diagnostics.markdownlint,
  diagnostics.ruff,
  diagnostics.pylint,
  diagnostics.staticcheck,
  diagnostics.tfsec,
  diagnostics.tsc,
  diagnostics.yamllint,
  diagnostics.zsh,
  diagnostics.trivy,
  diagnostics.hadolint,

  formatting.autoflake,
  formatting.autopep8,
  formatting.black,
  formatting.buf,
  formatting.cbfmt,
  formatting.clang_format,
  formatting.cmake_format,
  formatting.csharpier,
  formatting.prettier,
  formatting.fixjson,
  formatting.gofmt,
  formatting.gofumpt,
  formatting.goimports,
  formatting.golines,
  formatting.isort,
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
  formatting.stylua,
  formatting.taplo,

  hover.dictionary,
  hover.printenv,
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { async = true, bufnr = bufnr }
        end,
      })
    end
  end,
}

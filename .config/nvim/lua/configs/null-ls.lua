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
  --diagnostics.shellcheck, Replaced with bashls lsp.
  diagnostics.buf,
  diagnostics.checkmake,
  diagnostics.checkstyle,
  --diagnostics.clang_check, Replaced with clangd lsp.
  diagnostics.cmake_lint,
  diagnostics.cppcheck,
  --diagnostics.cpplint, Replaced with clangd lsp.
  --diagnostics.eslint, Replaced with eslint lsp.
  diagnostics.dotenv_linter,
  --diagnostics.flake8, Replaced with ruff-lsp lsp.
  -- Configure mypy to use the virtual environment if present.
  -- https://stackoverflow.com/questions/76487150/how-to-avoid-cannot-find-implementation-or-library-stub-when-mypy-is-installed
  diagnostics.mypy.with {
    extra_args = function()
      local virtual = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX" or "/usr"
      return { "--python-executable", virtual .. "/bin/python" }
    end,
  },
  --diagnostics.pyproject_flake8, Replaced with ruff lsp.
  --diagnostics.luacheck, Replaced with selene.
  diagnostics.selene,
  diagnostics.markdownlint,
  --diagnostics.ruff, Replaced with ruff lsp
  diagnostics.pylint,
  diagnostics.staticcheck,
  diagnostics.tfsec,
  --diagnostics.tsc,
  diagnostics.yamllint,
  diagnostics.zsh,
  diagnostics.trivy,
  diagnostics.hadolint,

  --formatting.autoflake, Replaced with ruff lsp
  --formatting.autopep8, Replaced with ruff lsp
  formatting.black,
  formatting.buf,
  formatting.cbfmt,
  formatting.clang_format,
  formatting.cmake_format,
  formatting.csharpier,
  formatting.prettier,
  --formatting.fixjson, Replaced with jsonls
  formatting.gofmt,
  formatting.gofumpt,
  formatting.goimports,
  formatting.golines,
  formatting.isort,
  formatting.markdownlint,
  --formatting.ruff, Replaced with ruff lsp
  --formatting.rustfmt, Replaced with rust-analyzer lsp
  formatting.shellharden,
  formatting.shfmt,
  formatting.sqlfluff,
  formatting.sql_formatter,
  --formatting.terrafmt,
  formatting.terraform_fmt,
  formatting.textlint,
  formatting.yamlfmt,
  --formatting.zigfmt, Replaced with zls lsp
  formatting.stylua,
  --formatting.taplo,

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
          -- Setting async=true causes issues with buffers saving.
          vim.lsp.buf.format { async = false, bufnr = bufnr }
        end,
      })
    end
  end,
}

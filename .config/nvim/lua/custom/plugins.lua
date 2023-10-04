local plugins = {
  {
    "github/copilot.vim",
    lazy=false
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
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  }
}


return plugins

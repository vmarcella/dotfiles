---@type ChadrcConfig
local M = {}

M.ui = { theme = 'onedark' }
M.plugins = 'custom.plugins'

local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  M.cmp = {
    mapping = {
        ['<Tab>'] = cmp.mapping(function(fallback)
          local suggestion = require("copilot.suggestion")
          if suggestion.is_visible() then
              suggestion.accept()
          elseif cmp.visible() then
              cmp.confirm({ select = true })
          elseif has_words_before() then
              cmp.complete()
          else
              fallback()
          end
      end, { "i", "c" })
    }
  }
end




return M

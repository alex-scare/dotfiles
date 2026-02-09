return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
  },
  build = ":TSUpdate",
  lazy = false,
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local treesitter = require("nvim-treesitter")
    treesitter.install({ "lua", "dart", "go" })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'go', 'lua', 'dart' },
      callback = function() vim.treesitter.start() end,
    })

    require("treesitter-context").setup({})
  end,
}

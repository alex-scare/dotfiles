return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  lazy = false,                    -- neo-tree will lazily load itself
  config = function()
    vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal float <CR>', { desc = 'Show Directory tree' })
    vim.keymap.set('n', '<leader>N', ':Neotree git_status reveal float <CR>', { desc = 'Show Git tree' })
  end
}

return {
  -- colorschemes
  {
    "santos-gabriel-dario/darcula-solid.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    enabled = false,
    lazy = false,
    config = function()
      vim.cmd.colorscheme "darcula-solid"
    end
  },
  {
    "RRethy/base16-nvim",
    enabled = false,
    laze = false,
    config = function()
      vim.cmd.colorscheme "base16-tomorrow-night"
    end
  },
  {
    "catppuccin/nvim",
    enabled = true,
    lazy = false,
    config = function()
      vim.cmd.colorscheme "catppuccin-frappe"
    end
  },
  {
    "VonHeikemen/little-wonder",
    enabled = false,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'lw-mariana'
    end
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    enabled = false,
    lazy = false,
    config = function()
      require('rose-pine').setup({
        variant = "dawn",      -- auto, main, moon, or dawn
        dark_variant = "moon", -- main, moon, or dawn
      })
      vim.cmd.colorscheme 'rose-pine-moon'
    end
  },
  {
    "p00f/alabaster.nvim",
    lazy = false,
    enabled = false,
    config = function()
      vim.cmd.colorscheme "alabaster"
    end
  },
}

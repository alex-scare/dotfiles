return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
  },
  build = ":TSUpdate",
  lazy = false,
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "bash",
        "css",
        "dart",
        "go",
        "gomod",
        "gowork",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "lua",
        "markdown",
        "typescript",
        "typescriptreact",
        "yaml",
      },
      callback = function(ev)
        vim.treesitter.start(ev.buf)
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    require("treesitter-context").setup({})
  end,
}

local git_fugitive_full = function()
  vim.cmd('Git')
  vim.cmd("only")
end

return {
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", git_fugitive_full, { desc = "Fugitive: [G]it [S]tate Panel" })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 0,
          virt_text_priority = 100,
          use_focus = true,
        },
      })

      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk_inline<CR>',
        { desc = "[G]itSigns: Toggle Hunk [P]review" }
      )
      vim.keymap.set('n', 'gn', function()
        require('gitsigns').nav_hunk('next')
      end, { desc = "[G]itSigns: [N]ext hunk" })
      vim.keymap.set('n', 'gN', function()
        require('gitsigns').nav_hunk('prev')
      end, { desc = "[G]itSigns: Prev hunk" })
    end
  },
}

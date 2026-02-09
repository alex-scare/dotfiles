return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      map("<leader><leader>", builtin.find_files, "Telescope [F]ind Files")
      map("<leader>?", builtin.oldfiles, "[?] Find Recently Opened Files")
      map("<leader>fg", builtin.live_grep, "Telescope [F]ind Fuzzy")
      map("<leader>fs", builtin.grep_string, "Telescope [F]ind [S]tring")
      map("<leader>n", function()
        builtin.buffers({
          sort_lastused = true,
          ignore_current_buffer = true,
        })
      end, "Telescope [B]uffers")
      map("<leader>fh", builtin.help_tags, "Telescope [H]elp Tags")
      map("<leader>fd", builtin.diagnostics, "Telescope [D]iagnostics")
      map("<leader>fk", builtin.keymaps, "Telescope [K]eymaps Menu")
      map("<leader>u", "<cmd>Telescope undo<cr>", "Telescope [U]ndo History")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            ".idea",
            ".cache",
            ".github",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
            follow = false,
          },
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({}),
          undo = {},
        },
      })

      telescope.load_extension("ui-select")
      telescope.load_extension("undo")
    end,
  },
}

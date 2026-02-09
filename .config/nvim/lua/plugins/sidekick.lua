return {
  "folke/sidekick.nvim",
  lazy = false,
  opts = {
    nes = { enabled = false },
    cli = {
      win = {
        keys = {
          hide_n = { "<leader>q", "hide", mode = "n" },
        },
      },
      tools = {
        codex = { cmd = { "codex", "--search" } },
      },
      mux = {
        backend = "tmux",
        watch = true,
        enabled = true,
        create = 'split'
      },
      prompts = {
        changes              = "Can you review my changes?",
        diagnostics          = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
        diagnostics_workspac = "Can you help me fix these diagnostics?\n{diagnostics_all}",
        document             = "Add documentation to {function|line}",
        explain              = "Explain {this}",
        fix                  = "I need you to fix {this}",
        optimize             = "How can {this} be optimized?",
        review               = "I need you to critically review this {file} for any vulnerabilities and code smells.",
        tests                = "I need you to cover {this} with tests. Use testcontainers if suitable",
        -- simple context prompts
        buffers              = "{buffers}",
        file                 = "{file}",
        line                 = "{line}",
        position             = "{position}",
        quickfix             = "{quickfix}",
        selection            = "{selection}",
        ["function"]         = "{function}",
      },
    },

  },
  keys = {
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle() end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select({ filter = { installed = true } })
      end,
      desc = "Select CLI",
    },
    {
      "<leader>ad",
      function() require("sidekick.cli").close() end,
      desc = "Detach a CLI Session",
    },
    {
      "<leader>at",
      function() require("sidekick.cli").send({ msg = "{this}" }) end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function() require("sidekick.cli").send({ msg = "{file}" }) end,
      desc = "Send File",
    },
    {
      "<leader>av",
      function() require("sidekick.cli").send({ msg = "{selection}" }) end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<leader>ac",
      function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
      desc = "Sidekick Toggle Claude",
    },
  },
}

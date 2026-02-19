local function set_diag_hl()
  local hl = vim.api.nvim_set_hl
  hl(0, "DiagnosticVirtualTextError", { link = "DiagnosticError" })
  hl(0, "DiagnosticVirtualTextWarn", { link = "DiagnosticWarn" })
  hl(0, "DiagnosticVirtualTextInfo", { link = "DiagnosticInfo" })
  hl(0, "DiagnosticVirtualTextHint", { link = "DiagnosticHint" })
  hl(0, "DiagnosticFloatingError", { link = "DiagnosticError" })
  hl(0, "DiagnosticFloatingWarn", { link = "DiagnosticWarn" })
  hl(0, "DiagnosticFloatingInfo", { link = "DiagnosticInfo" })
  hl(0, "DiagnosticFloatingHint", { link = "DiagnosticHint" })
  hl(0, "FloatBorder", { link = "DiagnosticInfo" })
end

local function diag_prefix(diagnostic)
  if diagnostic.severity == vim.diagnostic.severity.ERROR then
    return "✘ "
  elseif diagnostic.severity == vim.diagnostic.severity.WARN then
    return "▲ "
  elseif diagnostic.severity == vim.diagnostic.severity.INFO then
    return " "
  else
    return " "
  end
end

local diagnostic_config = {
  virtual_text = {
    spacing = 2,
    prefix = diag_prefix,
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- servers: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local servers = {
  bashls = {},

  lua_ls = {
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },

  ts_ls = {
    capabilities = capabilities,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    init_options = {
      hostInfo = "neovim",
    },
  },

  gopls = {
    capabilities = capabilities,
    settings = {
      gopls = {
        gofumpt = true,
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
          nilness = true,
          unusedwrite = true,
          shadow = true,
        },
        hints = {
          parameterNames = true,
          rangeVariableTypes = true,
          constantValues = true,
          assignVariableTypes = true,
        },
      },
    },
  },

  golangci_lint_ls = {
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150, -- default is higher
    },

  },

  dartls = {
    capabilities = capabilities,
    settings = {
      dart = {
        enableSdkFormatter = true,
        lineLength = 80,
        completeFunctionCalls = true,
        showTodos = true,
      },
    },
  },
}

return {
  -- Mason ------------------------------------------------
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- LSPs -------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local telescope_builtin = require("telescope.builtin")

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "<leader>h", vim.lsp.buf.hover, "LSP: [H]over")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: [C]ode [A]ction")
          map("n", "gd", vim.lsp.buf.definition, "LSP: [G]oto [D]efinition")
          map("n", "gr", telescope_builtin.lsp_references, "LSP: [G]oto [R]eferences")
          map("n", "gi", telescope_builtin.lsp_implementations, "LSP: [G]oto [I]mplementation")
          map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: [R]e[N]ame symbol")
        end,
      })

      -- Register configs + enable servers
      local enable_list = {}
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
        table.insert(enable_list, name)
      end
      vim.lsp.enable(enable_list)

      -- Format on save (Lua)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.lua",
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })

      -- Format on save (Golang)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = '*.go',
        callback = function()
          vim.lsp.buf.format({ async = false })
        end
      })

      -- Format on save (Dart)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.dart",
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })

      -- Color virtual text
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_diag_hl,
      })
      set_diag_hl()

      -- vim diagnostics
      vim.diagnostic.config(diagnostic_config)

      -- Go run shortcut
      vim.keymap.set("n", "<leader>R", function()
        vim.cmd("!go run " .. vim.fn.shellescape(vim.fn.expand("%:p")))
      end)
    end,
  },
}

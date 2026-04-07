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

local prettier_filetypes = {
  css = true,
  html = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  markdown = true,
  scss = true,
  typescript = true,
  typescriptreact = true,
  yaml = true,
}

local function has_formatter(bufnr)
  return next(vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/formatting",
  })) ~= nil
end

local function format_with_prettier(bufnr)
  local prettier = vim.fn.exepath("prettier")
  if prettier == "" then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  if not prettier_filetypes[filetype] then
    return false
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return false
  end

  local input = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  if vim.bo[bufnr].endofline then
    input = input .. "\n"
  end

  local output = vim.fn.system({ prettier, "--stdin-filepath", filename }, input)
  if vim.v.shell_error ~= 0 then
    vim.notify("Prettier failed for " .. filename, vim.log.levels.WARN, { title = "Format" })
    return false
  end

  if output == input then
    return true
  end

  local view = vim.fn.winsaveview()
  local lines = vim.split(output, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modified = true
  vim.fn.winrestview(view)
  return true
end

local function format_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modifiable then
    return
  end

  if format_with_prettier(bufnr) then
    return
  end

  if has_formatter(bufnr) then
    vim.lsp.buf.format({ async = false, bufnr = bufnr })
  end
end

-- servers: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local servers = {
  bashls = {
    capabilities = capabilities,
  },

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
      "typescript",
      "typescriptreact",
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
    config = function(_, opts)
      require("mason").setup(opts)

      local registry = require("mason-registry")
      local packages = {
        "bash-language-server",
        "golangci-lint-langserver",
        "gopls",
        "lua-language-server",
        "typescript-language-server",
      }

      local function ensure_installed()
        for _, name in ipairs(packages) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end

      if registry.refresh then
        registry.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
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

      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(ev)
          format_buffer(ev.buf)
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
      vim.keymap.set("n", "<leader>f", function()
        format_buffer(vim.api.nvim_get_current_buf())
      end, { desc = "Format current buffer" })
    end,
  },
}

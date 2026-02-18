return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
    config = function()
      local ok_lualine, lualine = pcall(require, "lualine")
      if not ok_lualine then
        return
      end

      local function dap_status()
        local ok, dap = pcall(require, "dap")
        if not ok then
          return ""
        end

        local s = dap.status()
        if s == "" then
          return ""
        end

        s = s:lower()
        if s:find("running", 1, true) then return "R" end
        if s:find("paused", 1, true) then return "P" end
        if s:find("stopped", 1, true) then return "S" end
        if s:find("terminated", 1, true) or s:find("exited", 1, true) then return "T" end
        if s:find("initial", 1, true) or s:find("starting", 1, true) then return "I" end
        if s:find("disconnect", 1, true) then return "D" end

        return "•" -- fallback: some unknown state
      end

      lualine.setup({
        options = {
          theme = 'catppuccin',
          icons_enabled = true,
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(str) return str:sub(1, 1) end
            }
          },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {
            {
              'filename',
              path = 1,
              shorting_target = 10,
              symbols = {
                modified = '',
                readonly = '',
              }
            },
          },
          lualine_x = {
            {
              'lsp_status',
              icon = '',
              separator = '|',
              fmt = function(str)
                str = str:gsub("gopls", "go")
                str = str:gsub("golangci_lint_ls", "golint")
                return str
              end,
            }
          },
          lualine_y = { { dap_status, icon = '', separator = '|' } },
          lualine_z = {
            { "progress", padding = { left = 1, right = 1 } },
            { "location", padding = { left = 0, right = 1 } },
          },

        },
      })
    end
  },
}

return {
  {
    'arnamak/stay-centered.nvim',
    lazy = false,
    enabled = true,
    opts = {
      skip_filetypes = { 'lua' },
    },
    config = function(_, opts)
      require('stay-centered').setup(opts)

      local skip = {}
      for _, ft in ipairs(opts.skip_filetypes or {}) do
        skip[ft] = true
      end

      vim.api.nvim_create_autocmd('BufReadPost', {
        callback = function()
          if skip[vim.bo.filetype] then
            return
          end
          if vim.bo.buftype ~= '' then
            return
          end
          vim.schedule(function()
            pcall(vim.cmd, 'normal! zz')
          end)
        end,
      })
    end,
  },
}

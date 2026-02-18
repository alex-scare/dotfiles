local readonly_patterns = {
  "**/node_modules/**",
  "/opt/homebrew/**",
}

local function matches_patterns(path)
  for _, pat in ipairs(readonly_patterns) do
    local re = vim.regex(vim.fn.glob2regpat(pat))
    if re and re:match_str(path) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" then
      return
    end
    path = vim.fn.fnamemodify(path, ":p")
    if matches_patterns(path) then
      vim.bo[args.buf].modifiable = false
      vim.bo[args.buf].readonly = true
      vim.bo[args.buf].modified = false
    end
  end,
})

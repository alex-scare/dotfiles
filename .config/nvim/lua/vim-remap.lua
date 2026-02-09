local opt = vim.opt
local g = vim.g

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.smartindent = true

opt.wrap = false

g.mapleader = ' '
g.maplocalleader = "\\"

opt.iskeyword:append("_")
vim.cmd.colorscheme('default')
opt.termguicolors = true


--vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })



local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostics: open [E]rror float")
map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics: open errors pane")
map("n", "[d", vim.diagnostic.goto_prev, "Diagnostics: prev")
map("n", "]d", vim.diagnostic.goto_next, "Diagnostics: next")

map("n", "<leader>m", "<cmd>only<CR>", "Window: only (close others)")

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Copy to System [C]lipboard" })
vim.keymap.set("n", "<leader>Y", '"+yy', { noremap = true, silent = true, desc = "Copy Line to System Clipboard" })

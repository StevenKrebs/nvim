local map = vim.keymap.set

-- Global keymaps
-- These are editor-level behaviors, not plugin-specific maps.

map("t", "<Esc>", function()
	return vim.bo.filetype == "fzf" and "<Esc>" or "<C-\\><C-n>"
end, { expr = true, desc = "Exit terminal mode" })

map("n", "k", function()
	return vim.v.count > 0 and "m'" .. vim.v.count .. "k" or "gk"
end, { expr = true, desc = "Up" })

map("n", "j", function()
	return vim.v.count > 0 and "m'" .. vim.v.count .. "j" or "gj"
end, { expr = true, desc = "Down" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "J", "mzJ`z", { desc = "Join lines" })

map("i", "<C-U>", "<C-G>u<C-U>")
map("i", "<C-W>", "<C-G>u<C-W>")

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Unindent" })
map("v", ">", ">gv", { desc = "Indent" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })
